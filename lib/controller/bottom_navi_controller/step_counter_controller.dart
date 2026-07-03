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
  int lastSavedSteps = 0;
  Timer? _saveTimer;
  String? uid;
  String? email;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      saveSteps();
    }
  }

  final RxString searchQuery = ''.obs;

  RxDouble stepprogress = 0.0.obs;
  int stepgoal = 10000;
  RxList<ChartModel> chartData = <ChartModel>[].obs;

  //steps{

  Function(int)? _stepListener;

  int baseSensorSteps = 0;
  int savedSteps = 0;
  bool isFirstSensorValue = true;
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
  // steps hive{

  Future<void> saveSteps() async {
    final dateKey = getTodayKey();
    final userKey = getUserKey(dateKey);

    if (userKey == null) return;

    await stepsBox.put(userKey, steps.value);
  }

  Future<void> initTodayEntry() async {
    final dateKey = getTodayKey();
    final userKey = getUserKey(dateKey);

    if (userKey == null) return;

    if (!stepsBox.containsKey(userKey)) {
      await stepsBox.put(userKey, 0);
    }
  }

  //}
  Future<void> loadTodaySteps() async {
    final dateKey = getTodayKey();
    final userKey = getUserKey(dateKey);
    print("USER KEY: $userKey");
    print("STORED VALUE: ${stepsBox.get(userKey)}");
    if (userKey == null) return;
    savedSteps = stepsBox.get(userKey, defaultValue: 0);

    lastSavedSteps = savedSteps;

    steps.value = savedSteps;

    stepprogress.value = (steps.value / stepgoal).clamp(0.0, 1.0);
  }

  // ADDED: merge steps counted by the background isolate while app was closed
  Future<void> mergeBackgroundSteps() async {
    final todayKey = getTodayKey();
    final bgSteps = stepsBox.get('bg_steps_$todayKey', defaultValue: 0) as int;
    if (bgSteps > 0) {
      final userKey = getUserKey(todayKey);
      if (userKey == null) return;
      final current = stepsBox.get(userKey, defaultValue: 0) as int;
      final merged = current + bgSteps;
      await stepsBox.put(userKey, merged);
      // Clear background counter so it isn't double-added next time
      await stepsBox.put('bg_steps_$todayKey', 0);
      await stepsBox.put('bg_baseline_$todayKey', -1);
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

      // ALWAYS REMOVE OLD LISTENER
      if (_stepListener != null) {
        StepService.removeListener(_stepListener!);
        _stepListener = null;
      }

      resetData();

      if (uid != null) {
        isFirstSensorValue = true;

        await initTodayEntry();

        await mergeBackgroundSteps(); // ADDED
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

    if (status.isGranted) {
      _stepListener = (sensorSteps) async {
        // CHECK DATE CHANGE
        final todayKey = getTodayKey();

        if (todayKey != currentDateKey) {
          currentDateKey = todayKey;

          savedSteps = 0;

          baseSensorSteps = sensorSteps;

          steps.value = 0;

          stepprogress.value = 0.0;

          await saveSteps();

          return;
        }

        // FIRST SENSOR VALUE
        if (isFirstSensorValue) {
          baseSensorSteps = sensorSteps;

          isFirstSensorValue = false;

          steps.value = savedSteps;

          savedSteps = steps.value;

          lastSavedSteps = savedSteps;

          stepprogress.value = (steps.value / stepgoal).clamp(0.0, 1.0);

          return;
        }

        // NEW STEPS
        int newSteps = sensorSteps - baseSensorSteps;

        int calculatedSteps = savedSteps + newSteps;

        steps.value = calculatedSteps;

        // SAVE WITH DELAY
        _saveTimer?.cancel();

        _saveTimer = Timer(const Duration(seconds: 2), () async {
          await saveSteps();
        });

        stepprogress.value = (calculatedSteps / stepgoal).clamp(0.0, 1.0);
      };

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
