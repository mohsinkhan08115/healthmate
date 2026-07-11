package com.example.healthmate

import android.content.Context
import android.content.Intent
import androidx.core.content.ContextCompat
import androidx.work.Worker
import androidx.work.WorkerParameters

/**
 * Makes sure StepCounterService is running. Scheduled as periodic,
 * PERSISTED WorkManager work (see scheduleRestart() in StepCounterService).
 *
 * Why this exists in addition to BootReceiver: BootReceiver relies on the
 * app's own BroadcastReceiver being launched in response to BOOT_COMPLETED,
 * which is exactly the mechanism MIUI's "Autostart" permission blocks by
 * default for apps not on its allow-list. Persisted WorkManager work is
 * instead re-registered and triggered by Android's own JobScheduler/
 * AlarmManager system service after reboot — not by our app's receiver —
 * so it is not gated behind the same Autostart toggle. This is the
 * mechanism most fitness/tracking apps rely on for reboot resilience
 * on heavily-customized OEM skins (MIUI, ColorOS, FuntouchOS, etc.).
 *
 * Trade-off: minimum periodic interval WorkManager allows is 15 minutes,
 * so recovery isn't instant after boot the way a working BOOT_COMPLETED
 * receiver would be — but it self-heals within 15 minutes without
 * requiring the user to open the app.
 */
class StepServiceRestartWorker(context: Context, params: WorkerParameters) :
    Worker(context, params) {

    override fun doWork(): Result {
        val serviceIntent = Intent(applicationContext, StepCounterService::class.java)
        ContextCompat.startForegroundService(applicationContext, serviceIntent)
        return Result.success()
    }
}