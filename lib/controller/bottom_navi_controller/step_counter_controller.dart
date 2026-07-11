import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthmate/models/chart_model.dart';
import 'package:healthmate/models/food_model.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:healthmate/services/step_service.dart';

class StepsController extends GetxController with WidgetsBindingObserver {
  late Box stepsBox;
  RxInt steps = 0.obs;
  final RxList<foodModel> foods = <foodModel>[].obs;
  Timer? _saveTimer;
  String? uid;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      saveSteps();
    }

    // When the app comes back to the foreground, pull whatever the native
    // service recorded while we were away — covers the case where a push
    // update (onStepUpdate) was missed because the engine wasn't alive.
    if (state == AppLifecycleState.resumed) {
      syncFromNative();
    }
  }

  final RxString searchQuery = ''.obs;

  RxDouble stepprogress = 0.0.obs;
  int stepgoal = 10000;
  RxList<ChartModel> chartData = <ChartModel>[].obs;

  Function(int)? _stepListener;
  String currentDateKey = "";

  String getTodayKey() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  String? getUserKey(String date) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    if (uid == null) return null;
    return "${uid}_$date";
  }

  Future<void> saveSteps() async {
    final userKey = getUserKey(getTodayKey());
    if (userKey == null) return;
    await stepsBox.put(userKey, steps.value);
  }

  Future<void> initTodayEntry() async {
    final userKey = getUserKey(getTodayKey());
    if (userKey == null) return;
    if (!stepsBox.containsKey(userKey)) {
      await stepsBox.put(userKey, 0);
    }
  }

  /// Loads today's steps: Hive is just a local cache here, the native
  /// service is the source of truth, so we take whichever is higher.
  Future<void> loadTodaySteps() async {
    final userKey = getUserKey(getTodayKey());
    if (userKey == null) return;

    var savedSteps = stepsBox.get(userKey, defaultValue: 0) as int;

    final nativeSteps = await StepService.getStepsToday();
    if (nativeSteps > savedSteps) savedSteps = nativeSteps;

    steps.value = savedSteps;
    stepprogress.value = (steps.value / stepgoal).clamp(0.0, 1.0);
    await saveSteps();
  }

  /// Re-pulls from the native service and updates the UI + Hive if it's
  /// ahead of what we currently have. Cheap enough to call on every resume.
  Future<void> syncFromNative() async {
    final nativeSteps = await StepService.getStepsToday();
    if (nativeSteps > steps.value) {
      steps.value = nativeSteps;
      stepprogress.value = (steps.value / stepgoal).clamp(0.0, 1.0);
      await saveSteps();
    }
  }

  Future<void> loadChartDataFromHive() async {
    final List<ChartModel> tempList = [];

    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    if (uid == null) return;

    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));

      final dateKey =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      final userKey = "${uid}_$dateKey";
      final value = stepsBox.get(userKey, defaultValue: 0);

      tempList.add(
        ChartModel(
          value: value,
          day: date.weekday,
          date: date,
          color: value >= 10000 ? Colors.green : Colors.red,
        ),
      );
    }

    chartData.assignAll(tempList);
  }

  void resetData() {
    steps.value = 0;
    chartData.clear();
  }

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addObserver(this);
    stepsBox = Hive.box('stepsBox');
    currentDateKey = getTodayKey();

    FirebaseAuth.instance.authStateChanges().listen((user) async {
      uid = user?.uid;

      if (_stepListener != null) {
        StepService.removeListener(_stepListener!);
        _stepListener = null;
      }

      resetData();

      if (uid != null) {
        await initTodayEntry();
        await loadTodaySteps();
        await loadChartDataFromHive();
        initSteps();
      }
    });
  }

  int get weeklyStepsTotal =>
      chartData.fold(0, (sum, item) => sum + item.value);

  double get dailyAverage {
    if (chartData.isEmpty) return 0;
    int total = chartData.fold(0, (sum, item) => sum + item.value);
    return total / chartData.length;
  }

  void initSteps() async {
    var status = await Permission.activityRecognition.request();
    // Notification permission — without this on Android 13+, the native
    // foreground service can run but its notification may not be shown.
    await Permission.notification.request();
    // Reduces the chance of stock Android killing the foreground service
    // in the background. Note: this does NOT override OEM-specific
    // "autostart"/battery-manager restrictions on MIUI, ColorOS, etc. —
    // those require the user to manually allow autostart for the app in
    // their phone's own settings; there's no public API to do this for them.
    if (await Permission.ignoreBatteryOptimizations.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    }

    if (status.isGranted) {
      _stepListener = (nativeSteps) async {
        final todayKey = getTodayKey();

        if (todayKey != currentDateKey) {
          currentDateKey = todayKey;
          steps.value = 0;
          stepprogress.value = 0.0;
          await saveSteps();
          return;
        }

        if (nativeSteps > steps.value) {
          steps.value = nativeSteps;
          stepprogress.value = (steps.value / stepgoal).clamp(0.0, 1.0);

          _saveTimer?.cancel();
          _saveTimer = Timer(const Duration(seconds: 2), () async {
            await saveSteps();
          });
        }
      };

      // Registers the listener AND ensures the native service is running.
      StepService.initSteps(_stepListener!);

      debugPrint('STEP SERVICE STARTED');
    } else if (status.isDenied) {
      Get.snackbar(
        'Steps unavailable',
        'Allow "Physical Activity" permission to track your steps.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.orange.withOpacity(0.9),
        colorText: Colors.white,
      );
    } else if (status.isPermanentlyDenied) {
      Get.snackbar(
        'Steps unavailable',
        'Open Settings and enable "Physical Activity" permission for HealthMate.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 6),
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        mainButton: TextButton(
          onPressed: () => openAppSettings(),
          child: const Text(
            'Open Settings',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  int get tenKStreak {
    int streak = 0;
    for (var item in chartData) {
      if (item.value >= 10000) streak++;
    }
    return streak;
  }

  bool get weekendWarrior {
    return chartData.any((item) {
      final isWeekend = item.day == 6 || item.day == 7;
      final hasSteps = item.value >= 12000;
      return isWeekend && hasSteps;
    });
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveTimer?.cancel();
    saveSteps();
    if (_stepListener != null) {
      StepService.removeListener(_stepListener!);
      _stepListener = null;
    }
    super.onClose();
  }
}
