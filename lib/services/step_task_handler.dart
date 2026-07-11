// import 'dart:async';
// import 'package:flutter_foreground_task/flutter_foreground_task.dart';
// import 'package:pedometer/pedometer.dart';
// import 'package:hive/hive.dart';

// /// Runs inside the foreground service — keeps working even when
// /// the Flutter UI is completely closed.
// class StepTaskHandler extends TaskHandler {
//   StreamSubscription<StepCount>? _stepSubscription;

//   // The RAW cumulative count from the hardware sensor since last
//   // device reboot. This number only ever goes UP (or resets on reboot).
//   int _rawSensorSteps = 0;

//   // The step count value that was already stored as "today's baseline"
//   // — i.e. what the raw sensor read at the start of today.
//   int _todayBaselineSteps = 0;

//   late Box stepsBox;

//   @override
//   Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
//     // Hive must be initialized again here — this runs in an isolate
//     // separate from your main app's memory.
//     stepsBox = await Hive.openBox('stepsBox');

//     _todayBaselineSteps = stepsBox.get('baseline_$_todayKey', defaultValue: -1);

//     // Listen to the hardware step counter sensor (TYPE_STEP_COUNTER)
//     _stepSubscription = Pedometer.stepCountStream.listen(
//       _onStepCount,
//       onError: (e) => print('Step sensor error: $e'),
//     );
//   }

//   void _onStepCount(StepCount event) {
//     _rawSensorSteps = event.steps;

//     // First time ever running (or after reboot) — establish baseline
//     if (_todayBaselineSteps == -1) {
//       _todayBaselineSteps = _rawSensorSteps;
//       stepsBox.put('baseline_$_todayKey', _todayBaselineSteps);
//     }

//     // Handle device reboot: raw sensor resets to near-0 after reboot,
//     // so if raw < baseline, the sensor restarted — reset baseline.
//     if (_rawSensorSteps < _todayBaselineSteps) {
//       _todayBaselineSteps = _rawSensorSteps;
//       stepsBox.put('baseline_$_todayKey', _todayBaselineSteps);
//     }

//     final todaySteps = _rawSensorSteps - _todayBaselineSteps;

//     // Save today's step count to Hive so the UI can read it later
//     stepsBox.put('steps_$_todayKey', todaySteps);
//     stepsBox.put('lastRawSensorValue', _rawSensorSteps);

//     // Update the persistent notification text
//     FlutterForegroundTask.updateService(
//       notificationTitle: 'HealthMate — Tracking Steps',
//       notificationText: '$todaySteps steps today',
//     );

//     // Send the value to the UI too, in case app is open right now
//     FlutterForegroundTask.sendDataToMain(todaySteps);
//   }

//   String get _todayKey {
//     final now = DateTime.now();
//     return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
//   }

//   @override
//   Future<void> onRepeatEvent(DateTime timestamp) async {
//     // Not used — we react to sensor events directly instead of polling
//   }

//   @override
//   Future<void> onDestroy(DateTime timestamp) async {
//     await _stepSubscription?.cancel();
//   }
// }
