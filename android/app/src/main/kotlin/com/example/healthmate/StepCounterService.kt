package com.example.healthmate

import android.app.*
import android.content.*
import android.hardware.*
import android.os.*
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
            deContext.moveSharedPreferencesFrom(baseContext, "step_prefs")
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
        createNotificationChannel()
        if (Build.VERSION.SDK_INT >= 34) {
            startForeground(
                NOTIF_ID,
                buildNotification("Loading steps…"),
                android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_HEALTH
            )
        } else {
            startForeground(NOTIF_ID, buildNotification("Loading steps…"))
        }
        sensorManager = getSystemService(SENSOR_SERVICE) as SensorManager
        stepSensor = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
        midnightCheckHandler.postDelayed(midnightCheckRunnable, 60_000L)
        scheduleRestartWorker()
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
        // Load saved values for today
        cachedDateKey = todayKey()
        baseline = prefs.getInt("baseline_$cachedDateKey", -1)
        todaySteps = prefs.getInt("steps_$cachedDateKey", 0)

        // Show last known step count immediately instead of "0"
        updateNotification(todaySteps)
        sendStepsToFlutter(todaySteps)

        if (stepSensor == null) {
            // Device has no step counter hardware — nothing more to do.
            updateNotification("Step sensor not available on this device")
            return START_STICKY
        }

        sensorManager.unregisterListener(this)
        sensorManager.registerListener(this, stepSensor, SensorManager.SENSOR_DELAY_NORMAL)

        scheduleRestartWorker()

        return START_STICKY // ask the OS to restart this service if it's killed
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event?.sensor?.type != Sensor.TYPE_STEP_COUNTER) return
        val rawSteps = event.values[0].toInt()
        val todayKey = todayKey()

        // Midnight rollover
        if (todayKey != cachedDateKey) {
            cachedDateKey = todayKey
            baseline = -1
            todaySteps = 0
        }

        if (baseline == -1) {
            // First reading today, or first reading ever after this
            // service (re)started — preserve whatever was already counted.
            baseline = rawSteps - todaySteps
            prefs.edit().putInt("baseline_$todayKey", baseline).apply()
        } else if (rawSteps < todaySteps + baseline) {
            // Sensor counter reset (device rebooted mid-day) — recompute
            // baseline so todaySteps continues from where it left off
            // instead of dropping to 0.
            baseline = rawSteps - todaySteps
            prefs.edit().putInt("baseline_$todayKey", baseline).apply()
        }

        todaySteps = rawSteps - baseline
        if (todaySteps < 0) todaySteps = 0

        prefs.edit().putInt("steps_$todayKey", todaySteps).apply()

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