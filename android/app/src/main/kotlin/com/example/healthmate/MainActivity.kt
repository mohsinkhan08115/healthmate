package com.example.healthmate

import android.content.ActivityNotFoundException
import android.content.ComponentName
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        var stepChannel: MethodChannel? = null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        stepChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.example.healthmate/steps"
        ).also { channel ->

            channel.setMethodCallHandler { call, result ->
                when (call.method) {

                    "getStepsToday" -> {
                        val safeContext = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                            createDeviceProtectedStorageContext().also { deContext ->
                                deContext.moveSharedPreferencesFrom(this, "step_prefs")
                            }
                        } else {
                            this
                        }
                        val prefs = safeContext.getSharedPreferences("step_prefs", MODE_PRIVATE)

                        val c = java.util.Calendar.getInstance()
                        val y = c.get(java.util.Calendar.YEAR)
                        val m = (c.get(java.util.Calendar.MONTH) + 1)
                            .toString()
                            .padStart(2, '0')
                        val d = c.get(java.util.Calendar.DAY_OF_MONTH)
                            .toString()
                            .padStart(2, '0')

                        val today = "$y-$m-$d"

                        result.success(prefs.getInt("steps_$today", 0))
                    }

                    "getStoredSteps" -> {
                        val safeContext = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                            createDeviceProtectedStorageContext().also { deContext ->
                                deContext.moveSharedPreferencesFrom(this, "step_prefs")
                            }
                        } else {
                            this
                        }
                        val prefs = safeContext.getSharedPreferences("step_prefs", MODE_PRIVATE)
                        val allPrefs = prefs.all
                        val stepsMap = mutableMapOf<String, Int>()
                        for ((key, value) in allPrefs) {
                            if (key.startsWith("steps_") && value is Int) {
                                val dateKey = key.substring(6)
                                stepsMap[dateKey] = value
                            }
                        }
                        result.success(stepsMap)
                    }

                    "startStepService" -> {
                        val serviceIntent = Intent(this, StepCounterService::class.java)
                        ContextCompat.startForegroundService(this, serviceIntent)
                        result.success(true)
                    }

                    "openAutoStartSettings" -> {
                        openAutoStartSettings()
                        result.success(true)
                    }

                    "needsAutoStartSettings" -> {
                        val manufacturer = Build.MANUFACTURER.lowercase()
                        val isCandidate = manufacturer.contains("xiaomi") ||
                                          manufacturer.contains("oppo") ||
                                          manufacturer.contains("vivo") ||
                                          manufacturer.contains("huawei") ||
                                          manufacturer.contains("honor")
                        result.success(isCandidate)
                    }

                    else -> result.notImplemented()
                }
            }
        }

        ContextCompat.startForegroundService(
            this,
            Intent(this, StepCounterService::class.java)
        )
    }

    /**
     * Opens the manufacturer-specific "autostart" / "allow background
     * activity" settings screen. This is NOT a standard Android API —
     * each OEM (Xiaomi, Oppo, Vivo, Huawei) hides this behind its own
     * proprietary security app with its own component names, which can
     * also change between firmware versions. We try known component
     * names for the current manufacturer, in order, and fall back to
     * the app's own details page (where the user can at least reach
     * battery settings) if none of them resolve.
     */
    private fun openAutoStartSettings() {
        val manufacturer = Build.MANUFACTURER.lowercase()
        val candidates = mutableListOf<Intent>()

        when {
            manufacturer.contains("xiaomi") -> {
                candidates.add(Intent().setComponent(
                    ComponentName(
                        "com.miui.securitycenter",
                        "com.miui.permcenter.autostart.AutoStartManagementActivity"
                    )
                ))
            }
            manufacturer.contains("oppo") -> {
                candidates.add(Intent().setComponent(
                    ComponentName(
                        "com.coloros.safecenter",
                        "com.coloros.safecenter.permission.startup.StartupAppListActivity"
                    )
                ))
                candidates.add(Intent().setComponent(
                    ComponentName(
                        "com.oppo.safe",
                        "com.oppo.safe.permission.startup.StartupAppListActivity"
                    )
                ))
            }
            manufacturer.contains("vivo") -> {
                candidates.add(Intent().setComponent(
                    ComponentName(
                        "com.vivo.permissionmanager",
                        "com.vivo.permissionmanager.activity.BgStartUpManagerActivity"
                    )
                ))
            }
            manufacturer.contains("huawei") || manufacturer.contains("honor") -> {
                candidates.add(Intent().setComponent(
                    ComponentName(
                        "com.huawei.systemmanager",
                        "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity"
                    )
                ))
            }
        }

        // Fallback for Samsung and anything else / if the above fail:
        // app's own details screen, where battery settings are reachable.
        candidates.add(
            Intent(
                Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                Uri.parse("package:$packageName")
            )
        )

        for (intent in candidates) {
            try {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
                return
            } catch (e: ActivityNotFoundException) {
                // try the next candidate
            } catch (e: SecurityException) {
                // try the next candidate
            }
        }
    }

    override fun onDestroy() {
        stepChannel = null
        super.onDestroy()
    }
}