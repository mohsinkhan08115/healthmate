import 'package:flutter/services.dart';

/// Thin bridge to the native step counter.
///
/// All actual step counting happens in StepCounterService.kt — a native
/// Android foreground service that keeps running (and keeps showing the
/// notification) even when this Flutter engine is not running, and is
/// restarted directly by BootReceiver after a device reboot.
///
/// This class does NOT count steps itself and does NOT use pedometer or
/// flutter_foreground_task — those were removed because running a second,
/// independent step-counting/notification pipeline alongside the native
/// service was causing the notification conflicts and step-count drift.
class StepService {
  static const MethodChannel _channel = MethodChannel(
    'com.example.healthmate/steps',
  );

  static final List<Function(int)> _listeners = [];
  static bool _handlerAttached = false;

  /// Registers [onUpdate] to be called whenever the native service reports
  /// a new step count, and makes sure the native service is running.
  static void initSteps(Function(int) onUpdate) {
    if (!_listeners.contains(onUpdate)) {
      _listeners.add(onUpdate);
    }
    _attachHandler();
    // Idempotent — safe to call even if the service is already running.
    _channel.invokeMethod('startStepService');
  }

  static void removeListener(Function(int) listener) {
    _listeners.remove(listener);
  }

  static void _attachHandler() {
    if (_handlerAttached) return;
    _handlerAttached = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onStepUpdate') {
        final steps = call.arguments as int;
        for (final listener in List<Function(int)>.from(_listeners)) {
          listener(steps);
        }
      }
    });
  }

  /// Pull-based sync — call on app resume / cold start to fetch whatever
  /// the native service has recorded, in case a push update (onStepUpdate)
  /// was missed while the app process wasn't alive.
  static Future<int> getStepsToday() async {
    try {
      return await _channel.invokeMethod<int>('getStepsToday') ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Retrieves all daily step counts stored in native SharedPreferences.
  static Future<Map<String, int>> getStoredSteps() async {
    try {
      final Map? result = await _channel.invokeMethod<Map>('getStoredSteps');
      if (result == null) return {};
      return result.cast<String, int>();
    } catch (_) {
      return {};
    }
  }

  /// Opens the manufacturer's autostart / background-activity settings
  /// screen (Xiaomi/Oppo/Vivo/Huawei have their own, separate from
  /// Android's own permission system). Wire this to a button in your
  /// Settings screen with an explanation, e.g. "If step tracking stops
  /// after restarting your phone, tap here to allow HealthMate to
  /// auto-start." Don't call this without user context — jumping
  /// straight to an OEM settings screen with no explanation is confusing.
  static Future<void> openAutoStartSettings() async {
    try {
      await _channel.invokeMethod('openAutoStartSettings');
    } catch (_) {}
  }

  static Future<bool> needsAutoStartSettings() async {
    try {
      return await _channel.invokeMethod<bool>('needsAutoStartSettings') ??
          false;
    } catch (_) {
      return false;
    }
  }
}
