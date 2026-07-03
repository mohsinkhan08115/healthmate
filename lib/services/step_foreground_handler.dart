import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:pedometer/pedometer.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Runs in a background isolate that survives even when the app UI/process
/// is closed. This is where the ACTUAL sensor listening must happen —
/// listening in the main isolate (old approach) dies when the app closes.
class StepForegroundHandler extends TaskHandler {
  StreamSubscription<StepCount>? _subscription;
  Box? _stepsBox;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // Hive needs to be initialized again here — separate isolate,
    // separate memory space from your main app.
    await Hive.initFlutter();
    _stepsBox = await Hive.openBox('stepsBox');

    _subscription = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: (e) => print('Background pedometer error: $e'),
    );
  }

  void _onStepCount(StepCount event) {
    final rawSteps = event.steps;
    final todayKey = _todayKey;

    // baseline = raw sensor value recorded at the start of today
    int baseline = _stepsBox?.get('bg_baseline_$todayKey', defaultValue: -1);

    if (baseline == -1 || rawSteps < baseline) {
      // first run today, OR device rebooted (sensor resets on reboot)
      baseline = rawSteps;
      _stepsBox?.put('bg_baseline_$todayKey', baseline);
    }

    final todaySteps = rawSteps - baseline;

    // This key format MATCHES what StepsController already reads:
    // "${uid}_${dateKey}" — but background isolate has no Firebase user,
    // so we store under a neutral key and merge it on the UI side.
    _stepsBox?.put('bg_steps_$todayKey', todaySteps);

    FlutterForegroundTask.updateService(
      notificationTitle: 'HealthMate',
      notificationText: '$todaySteps steps today',
    );

    // Pushes live value to the UI isolate IF the app is currently open
    FlutterForegroundTask.sendDataToMain(todaySteps);
  }

  String get _todayKey {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {}

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    await _subscription?.cancel();
  }
}

@pragma('vm:entry-point')
void startStepForegroundCallback() {
  FlutterForegroundTask.setTaskHandler(StepForegroundHandler());
}
