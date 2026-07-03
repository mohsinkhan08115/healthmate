import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:healthmate/services/step_service_manager.dart'; // ADDED

class StepService {
  static final StepService _instance = StepService._internal();

  factory StepService() => _instance;

  StepService._internal();

  bool _isListening = false;

  final List<Function(int)> _listeners = [];

  StreamSubscription<StepCount>? _subscription;

  // ─── Public static API ───────────────────────────────────────────────

  static void initSteps(Function(int) onUpdate) {
    _instance._addListener(onUpdate);
    _instance._startListening();
  }

  static void removeListener(Function(int) listener) {
    _instance._listeners.remove(listener);
  }

  static void dispose() {
    _instance._stopListening();
  }

  // ─── Private instance methods ────────────────────────────────────────

  void _addListener(Function(int) onUpdate) {
    if (!_listeners.contains(onUpdate)) {
      _listeners.add(onUpdate);
    }
  }

  void _startListening() {
    if (_isListening) return;

    _isListening = true;

    // ADDED: start the foreground service so Android doesn't kill this
    // process (and this pedometer subscription) when the app UI is closed.
    StepServiceManager.requestPermissions();
    StepServiceManager.startService();

    _subscription = Pedometer.stepCountStream.listen(
      (StepCount event) {
        for (var listener in List.from(_listeners)) {
          listener(event.steps);
        }
      },
      onError: (error) {
        print("Pedometer Error: $error");
      },
    );
  }

  void _stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _isListening = false;

    // ADDED: stop the foreground service when no one is listening anymore
    StepServiceManager.stopService();
  }
}
