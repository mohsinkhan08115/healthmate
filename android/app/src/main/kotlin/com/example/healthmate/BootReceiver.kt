package com.example.healthmate

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.core.content.ContextCompat

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        Log.d("HealthMateBoot", "BootReceiver: Received broadcast action: $action")

        when (action) {
            Intent.ACTION_LOCKED_BOOT_COMPLETED,
            Intent.ACTION_BOOT_COMPLETED,
            "android.intent.action.QUICKBOOT_POWERON",
            "com.htc.intent.action.QUICKBOOT_POWERON",
            "com.android.intent.action.QUICKBOOT_POWERON",
            Intent.ACTION_MY_PACKAGE_REPLACED -> {
                Log.d("HealthMateBoot", "BootReceiver: Attempting to start StepCounterService...")
                try {
                    val serviceIntent = Intent(context, StepCounterService::class.java)
                    ContextCompat.startForegroundService(context, serviceIntent)
                    Log.d("HealthMateBoot", "BootReceiver: startForegroundService called successfully.")
                } catch (e: Exception) {
                    Log.e("HealthMateBoot", "BootReceiver: Failed to start StepCounterService: ${e.message}", e)
                }
            }
            else -> {
                Log.d("HealthMateBoot", "BootReceiver: Action $action ignored.")
            }
        }
    }
}