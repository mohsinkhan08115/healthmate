package com.example.healthmate

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.content.ContextCompat

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_LOCKED_BOOT_COMPLETED,
            Intent.ACTION_BOOT_COMPLETED,
            "android.intent.action.QUICKBOOT_POWERON",
            "com.htc.intent.action.QUICKBOOT_POWERON",
            Intent.ACTION_MY_PACKAGE_REPLACED -> {
                // Start the native step service directly — no Flutter engine
                // needed, so the notification/counting resumes immediately
                // after reboot or an app update, without opening the app.
                val serviceIntent = Intent(context, StepCounterService::class.java)
                ContextCompat.startForegroundService(context, serviceIntent)
            }
        }
    }
}