// import 'dart:async';
// import 'package:flutter_foreground_task/flutter_foreground_task.dart';
// import 'package:pedometer/pedometer.dart';

// /// Runs in a background isolate that survives even when the app UI/process
// /// is closed. Uses FlutterForegroundTask's own storage (NOT Hive) because
// /// Hive is not safe for concurrent writes from two isolates at once —
// /// that was causing "Recovering corrupted box" and silent data loss.
// class StepForegroundHandler extends TaskHandler {
//   StreamSubscription<StepCount>? _subscription;
//   int _baseline = -1;
//   String _cachedDateKey = '';

//   @override
//   Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
//     _cachedDateKey = _todayKey;
//     _baseline =
//         await FlutterForegroundTask.getData<int>(
//           key: 'bg_baseline_$_cachedDateKey',
//         ) ??
//         -1;

//     // ADDED: show previously saved step count immediately on start
//     // instead of showing 0 until the next step arrives.
//     final previousSteps =
//         await FlutterForegroundTask.getData<int>(
//           key: 'bg_steps_$_cachedDateKey',
//         ) ??
//         0;

//     if (previousSteps > 0) {
//       FlutterForegroundTask.updateService(
//         notificationTitle: 'HealthMate',
//         notificationText: '$previousSteps steps today',
//       );
//       FlutterForegroundTask.sendDataToMain(previousSteps);
//     }

//     _subscription = Pedometer.stepCountStream.listen(
//       _onStepCount,
//       onError: (e) => print('Background pedometer error: $e'),
//     );
//   }

//   Future<void> _onStepCount(StepCount event) async {
//     final rawSteps = event.steps;
//     final todayKey = _todayKey;

//     // Date changed since task started — reset for the new day
//     if (todayKey != _cachedDateKey) {
//       _cachedDateKey = todayKey;
//       _baseline = -1;
//     }

//     if (_baseline == -1) {
//       // Very first run ever for today — no prior baseline exists yet.
//       _baseline = rawSteps;
//       await FlutterForegroundTask.saveData(
//         key: 'bg_baseline_$todayKey',
//         value: _baseline,
//       );
//     } else if (rawSteps < _baseline) {
//       // Reboot detected mid-day: the hardware sensor reset to ~0,
//       // but we don't want today's step count to reset to 0 too —
//       // so we recompute the baseline to CONTINUE from whatever
//       // was already counted today, instead of losing it.
//       final previousTodaySteps =
//           await FlutterForegroundTask.getData<int>(key: 'bg_steps_$todayKey') ??
//           0;

//       _baseline = rawSteps - previousTodaySteps;
//       if (_baseline < 0) _baseline = rawSteps; // safety fallback

//       await FlutterForegroundTask.saveData(
//         key: 'bg_baseline_$todayKey',
//         value: _baseline,
//       );
//     }

//     final todaySteps = rawSteps - _baseline;

//     // Uses flutter_foreground_task's own isolate-safe storage —
//     // NOT Hive — to avoid concurrent-write corruption.
//     await FlutterForegroundTask.saveData(
//       key: 'bg_steps_$todayKey',
//       value: todaySteps,
//     );

//     FlutterForegroundTask.updateService(
//       notificationTitle: 'HealthMate',
//       notificationText: '$todaySteps steps today',
//     );

//     FlutterForegroundTask.sendDataToMain(todaySteps);
//   }

//   String get _todayKey {
//     final now = DateTime.now();
//     return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
//   }

//   @override
//   Future<void> onRepeatEvent(DateTime timestamp) async {
//     // Runs every minute (see step_service_manager.dart) even if no
//     // steps have been taken yet — makes sure the notification resets
//     // right at midnight instead of waiting for the next step.
//     final todayKey = _todayKey;
//     if (todayKey != _cachedDateKey) {
//       _cachedDateKey = todayKey;
//       _baseline = -1;

//       FlutterForegroundTask.updateService(
//         notificationTitle: 'HealthMate',
//         notificationText: '0 steps today',
//       );
//       FlutterForegroundTask.sendDataToMain(0);
//     }
//   }

//   @override
//   Future<void> onDestroy(DateTime timestamp) async {
//     await _subscription?.cancel();
//   }
// }

// @pragma('vm:entry-point')
// void startStepForegroundCallback() {
//   FlutterForegroundTask.setTaskHandler(StepForegroundHandler());
// }
