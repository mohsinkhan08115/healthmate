package com.example.healthmate

import android.app.*
import android.content.*
import android.hardware.*
import android.os.*
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.work.Constraints
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import java.util.concurrent.TimeUnit

/**
 * Single source of truth for step counting.
 *
 * This is a plain native Android foreground service — it does NOT depend on
 * flutter_foreground_task, pedometer, or the Flutter engine being alive.
 * That's what lets it:
 *   - keep showing the notification when the app is backgrounded/killed
 *   - get started directly by BootReceiver right after a reboot
 *   - persist steps across reboots via SharedPreferences (no Hive — Hive
 *     is not safe to touch from a process where the Flutter engine may
 *     not even be running)
 *
 * Flutter talks to this service only through MainActivity's MethodChannel
 * (com.example.healthmate/steps) — this class doesn't know Flutter exists.
 */
class StepCounterService : Service(), SensorEventListener {

    private lateinit var sensorManager: SensorManager
    private var stepSensor: Sensor? = null
    private val prefs by lazy {
        val baseContext = applicationContext
        val safeContext = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val deContext = baseContext.createDeviceProtectedStorageContext()
            val um = baseContext.getSystemService(Context.USER_SERVICE) as UserManager
            if (um.isUserUnlocked) {
                try {
                    val migrated = deContext.moveSharedPreferencesFrom(baseContext, "step_prefs")
                    Log.d("HealthMateService", "Shared preferences migration completed: $migrated")
                } catch (e: Exception) {
                    Log.e("HealthMateService", "Failed to migrate shared preferences during unlock check: ${e.message}", e)
                }
            } else {
                Log.d("HealthMateService", "Device is locked. Skipping shared preferences migration (will run when unlocked).")
            }
            deContext
        } else {
            baseContext
        }
        safeContext.getSharedPreferences("step_prefs", Context.MODE_PRIVATE)
    }

    private val CHANNEL_ID = "healthmate_step_channel"
    private val NOTIF_ID = 1001

    private var baseline = -1
    private var todaySteps = 0
    private var cachedDateKey = ""

    // Checks every minute whether the date has changed, so the notification
    // and step count reset to 0 at midnight even if no step is taken and
    // the app isn't reopened (onSensorChanged alone can't catch this,
    // since it only fires when an actual step is detected).
    private val midnightCheckHandler = Handler(Looper.getMainLooper())
    private val midnightCheckRunnable = object : Runnable {
        override fun run() {
            checkMidnightRollover()
            midnightCheckHandler.postDelayed(this, 60_000L)
        }
    }

    private fun checkMidnightRollover() {
        val newKey = todayKey()
        if (newKey != cachedDateKey) {
            cachedDateKey = newKey
            baseline = -1
            todaySteps = 0
            prefs.edit().putInt("steps_$newKey", 0).apply()
            updateNotification(0)
            sendStepsToFlutter(0)
        }
    }

    private fun todayKey(): String {
        val c = java.util.Calendar.getInstance()
        val y = c.get(java.util.Calendar.YEAR)
        val m = (c.get(java.util.Calendar.MONTH) + 1).toString().padStart(2, '0')
        val d = c.get(java.util.Calendar.DAY_OF_MONTH).toString().padStart(2, '0')
        return "$y-$m-$d"
    }

    override fun onCreate() {
        super.onCreate()
        Log.d("HealthMateService", "StepCounterService: onCreate() called")
        
        Log.d("HealthMateNotification", "StepCounterService: Creating notification channel...")
        try {
            createNotificationChannel()
            Log.d("HealthMateNotification", "StepCounterService: Notification channel created successfully")
        } catch (e: Exception) {
            Log.e("HealthMateNotification", "StepCounterService: Failed to create notification channel: ${e.message}", e)
        }

        Log.d("HealthMateNotification", "StepCounterService: Calling startForeground()...")
        try {
            if (Build.VERSION.SDK_INT >= 34) {
                startForeground(
                    NOTIF_ID,
                    buildNotification("Loading steps…"),
                    android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_HEALTH
                )
            } else {
                startForeground(NOTIF_ID, buildNotification("Loading steps…"))
            }
            Log.d("HealthMateNotification", "StepCounterService: startForeground() succeeded")
        } catch (e: Exception) {
            Log.e("HealthMateNotification", "StepCounterService: Failed to call startForeground(): ${e.message}", e)
        }

        sensorManager = getSystemService(SENSOR_SERVICE) as SensorManager
        stepSensor = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
        if (stepSensor != null) {
            Log.d("HealthMateService", "StepCounterService: Step counter hardware sensor is available")
        } else {
            Log.e("HealthMateService", "StepCounterService: Step counter hardware sensor is NOT available on this device!")
        }

        midnightCheckHandler.postDelayed(midnightCheckRunnable, 60_000L)
        
        Log.d("HealthMateService", "StepCounterService: Scheduling periodic restart worker...")
        try {
            scheduleRestartWorker()
        } catch (e: Exception) {
            Log.e("HealthMateService", "StepCounterService: Failed to schedule restart worker: ${e.message}", e)
        }
    }

    /**
     * Registers a persisted periodic WorkManager job that ensures this
     * service is running, checked every 15 minutes (WorkManager's minimum
     * periodic interval). Uses KEEP so calling this repeatedly (every time
     * the service starts, regardless of what started it) doesn't reset or
     * duplicate the schedule — it's a no-op if already registered.
     *
     * This is what survives a reboot on MIUI even when the BOOT_COMPLETED
     * broadcast to BootReceiver is blocked by the Autostart permission —
     * see StepServiceRestartWorker for the full explanation.
     */
    private fun scheduleRestartWorker() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val um = getSystemService(Context.USER_SERVICE) as UserManager
            if (!um.isUserUnlocked) {
                // Cannot access WorkManager in Direct Boot (locked) mode.
                // We will schedule it once the user unlocks (via BOOT_COMPLETED).
                return
            }
        }
        val request = PeriodicWorkRequestBuilder<StepServiceRestartWorker>(
            15, TimeUnit.MINUTES
        ).setConstraints(Constraints.NONE).build()

        WorkManager.getInstance(applicationContext).enqueueUniquePeriodicWork(
            "step_service_restart",
            ExistingPeriodicWorkPolicy.KEEP,
            request
        )
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action
        Log.d("HealthMateService", "StepCounterService: onStartCommand() called with action: $action, flags: $flags, startId: $startId")

        // Load saved values for today
        cachedDateKey = todayKey()
        baseline = prefs.getInt("baseline_$cachedDateKey", -1)
        todaySteps = prefs.getInt("steps_$cachedDateKey", 0)
        Log.d("HealthMateService", "StepCounterService: Loaded cached steps for $cachedDateKey. Baseline: $baseline, TodaySteps: $todaySteps")

        // Show last known step count immediately instead of "0"
        updateNotification(todaySteps)
        sendStepsToFlutter(todaySteps)

        if (stepSensor == null) {
            // Device has no step counter hardware — nothing more to do.
            Log.e("HealthMateService", "StepCounterService: Step sensor is null in onStartCommand. Cannot track steps.")
            updateNotification("Step sensor not available on this device")
            return START_STICKY
        }

        // Check for activity recognition permission
        val hasPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            androidx.core.content.ContextCompat.checkSelfPermission(
                this,
                android.Manifest.permission.ACTIVITY_RECOGNITION
            ) == android.content.pm.PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
        Log.d("HealthMateService", "StepCounterService: ACTIVITY_RECOGNITION permission status: $hasPermission")

        Log.d("HealthMateService", "StepCounterService: Registering sensor listener...")
        sensorManager.unregisterListener(this)
        val registered = sensorManager.registerListener(this, stepSensor, SensorManager.SENSOR_DELAY_NORMAL)
        Log.d("HealthMateService", "StepCounterService: Sensor listener registration result: $registered")

        Log.d("HealthMateService", "StepCounterService: Scheduling periodic restart worker...")
        try {
            scheduleRestartWorker()
        } catch (e: Exception) {
            Log.e("HealthMateService", "StepCounterService: Failed to schedule restart worker: ${e.message}", e)
        }

        return START_STICKY // ask the OS to restart this service if it's killed
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event?.sensor?.type != Sensor.TYPE_STEP_COUNTER) return
        val rawSteps = event.values[0].toInt()
        val todayKey = todayKey()

        Log.d("HealthMateService", "StepCounterService: onSensorChanged() - rawSteps: $rawSteps")

        // Midnight rollover
        if (todayKey != cachedDateKey) {
            Log.d("HealthMateService", "StepCounterService: Date rollover detected. Old: $cachedDateKey, New: $todayKey")
            cachedDateKey = todayKey
            baseline = -1
            todaySteps = 0
        }

        if (baseline == -1) {
            // First reading today, or first reading ever after this
            // service (re)started — preserve whatever was already counted.
            baseline = rawSteps - todaySteps
            Log.d("HealthMateService", "StepCounterService: Set new baseline: $baseline (rawSteps: $rawSteps, todaySteps: $todaySteps)")
            prefs.edit().putInt("baseline_$todayKey", baseline).apply()
        } else if (rawSteps < todaySteps + baseline) {
            // Sensor counter reset (device rebooted mid-day) — recompute
            // baseline so todaySteps continues from where it left off
            // instead of dropping to 0.
            baseline = rawSteps - todaySteps
            Log.d("HealthMateService", "StepCounterService: Sensor reset detected. Recomputed baseline: $baseline (rawSteps: $rawSteps, todaySteps: $todaySteps)")
            prefs.edit().putInt("baseline_$todayKey", baseline).apply()
        }

        todaySteps = rawSteps - baseline
        if (todaySteps < 0) todaySteps = 0

        prefs.edit().putInt("steps_$todayKey", todaySteps).apply()

        Log.d("HealthMateService", "StepCounterService: Today's Steps: $todaySteps")

        updateNotification(todaySteps)
        sendStepsToFlutter(todaySteps)
    }

    private fun sendStepsToFlutter(steps: Int) {
        Handler(Looper.getMainLooper()).post {
            MainActivity.stepChannel?.invokeMethod("onStepUpdate", steps)
        }
    }

    private fun updateNotification(steps: Int) = updateNotification("$steps steps today")

    private fun updateNotification(text: String) {
        val manager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        manager.notify(NOTIF_ID, buildNotification(text))
    }

    private fun buildNotification(text: String): Notification {
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_NEW_TASK
        }
        val pi = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("HealthMate")
            .setContentText(text)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(pi)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Step Counter",
            NotificationManager.IMPORTANCE_LOW
        ).apply { description = "Keeps tracking your steps in the background" }
        (getSystemService(NOTIFICATION_SERVICE) as NotificationManager)
            .createNotificationChannel(channel)
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
    override fun onBind(intent: Intent?) = null

    override fun onDestroy() {
        sensorManager.unregisterListener(this)
        midnightCheckHandler.removeCallbacks(midnightCheckRunnable)
        super.onDestroy()
    }
}