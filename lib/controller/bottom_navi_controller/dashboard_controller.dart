import 'dart:async'; // ADDED: needed for Timer (used to auto-refresh at midnight)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:healthmate/controller/bottom_navi_controller/step_counter_controller.dart';
import 'package:healthmate/models/food_model.dart';
import 'package:hive/hive.dart';

class DashboardController extends GetxController {
  late StepsController stepsController;
  late Box foodBox;
  late Box historyBox;

  // CHANGED: `foods` now holds ALL of the user's food entries (all days),
  // exactly like before. We use this for weekly calculations.
  final RxList<foodModel> foods = <foodModel>[].obs;

  final RxList<dynamic> foodKeys = <dynamic>[].obs;
  final RxDouble totalCalories = 0.0.obs;
  final RxDouble totalProtein = 0.0.obs;
  final RxDouble totalWater = 0.0.obs;
  RxDouble stepsGoal = 10000.0.obs;
  RxDouble caloriesGoal = 2000.0.obs;
  RxDouble proteinGoal = 75.0.obs;
  RxDouble waterGoal = 2000.0.obs;

  // ADDED: keeps track of the date the dashboard was last calculated for.
  // Used to detect when a new day has started while the app is running.
  DateTime _lastCheckedDate = DateTime.now();

  // ADDED: timer that periodically checks if the date has changed
  // (handles the case where the app is left open across midnight).
  Timer? _dateCheckTimer;

  void updateGoals({
    required double steps,
    required double calories,
    required double protein,
    required double water,
  }) {
    stepsGoal.value = steps;
    caloriesGoal.value = calories;
    proteinGoal.value = protein;
    waterGoal.value = water;

    final box = Hive.box('profileBox');

    box.put('stepsGoal', steps);
    box.put('caloriesGoal', calories);
    box.put('proteinGoal', protein);
    box.put('waterGoal', water);
  }

  @override
  void onInit() {
    super.onInit();
    final box = Hive.box('profileBox');
    stepsGoal.value = (box.get('stepsGoal', defaultValue: 10000) as num)
        .toDouble();
    caloriesGoal.value = (box.get('caloriesGoal', defaultValue: 2000) as num)
        .toDouble();
    proteinGoal.value = (box.get('proteinGoal', defaultValue: 75) as num)
        .toDouble();
    waterGoal.value = (box.get('waterGoal', defaultValue: 2000) as num)
        .toDouble();

    stepsController = Get.find<StepsController>();
    foodBox = Hive.box('foodBox');
    historyBox = Hive.box('historyBox');
    checkNewDay();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      refreshDashboard();
    });

    // ADDED: store today's date as the "last checked" date on startup.
    _lastCheckedDate = DateTime.now();

    // ADDED: check every minute whether the date has changed.
    // If it has, freeze yesterday's run-km, then refresh the dashboard
    // so Today's Progress resets to zero automatically without needing
    // to restart the app.
    _dateCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      if (!_isSameDay(now, _lastCheckedDate)) {
        _freezeRunKmForDate(_lastCheckedDate); // ADDED: snapshot before reset
        _lastCheckedDate = now;
        refreshDashboard();
      }
    });
  }

  // ADDED: clean up the timer when the controller is disposed.
  @override
  void onClose() {
    _dateCheckTimer?.cancel();
    super.onClose();
  }

  // ADDED: helper to check if two DateTime objects fall on the same day.
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // ADDED: helper that returns a date-only key string (e.g. "2025-06-12").
  // Used to store water intake separately for each day.
  // CHANGED: zero-pad month and day so this matches the dateKey format
  // used in monthly_history.dart (e.g. "2026-06-12" instead of "2026-6-12")
  String _dateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // ADDED: saves today's (about-to-end) run-km estimate into Hive so it's
  // permanently frozen for that date and can be shown in Monthly History.
  // Uses the same '${uid}_runkm_$dateKey' pattern as water storage.
  void _freezeRunKmForDate(DateTime date) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final dateKey = _dateKey(date);

    foodBox.put('${uid}_run_$dateKey', estimatedRunKm);
  }

  void refreshDashboard() {
    loadFoods();
    loadWater();
    calculateNutrition();
  }

  // CHANGED: water is now stored per-day using a date-based key.
  // This means when a new day starts, there is simply no saved value
  // for that new date yet, so it automatically defaults to 0.
  void loadWater() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final todayKey = _dateKey(DateTime.now()); // ADDED
    final saved = foodBox.get(
      '${uid}_water_$todayKey', // CHANGED: was '${uid}_water'
      defaultValue: 0,
    );

    totalWater.value = (saved as num).toDouble();
  }

  // CHANGED: deleteFood now receives an index into `todaysFoods`
  // (the filtered list shown on the dashboard), and converts it
  // to the correct index in the full `foods` / underlying Hive list.
  // CHANGED: Recent Meals now shows ALL foods (controller.foods) directly,
  // so `index` corresponds directly to the position in `foods` and in
  // the underlying `userFoods` list in Hive (loadFoods() preserves order).
  // No more mapping through `todaysFoods` is needed.
  void deleteFood(int index) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    Map users = foodBox.get('users', defaultValue: {});
    List userFoods = users[uid] ?? [];

    if (index < 0 || index >= userFoods.length) return;

    userFoods.removeAt(index);

    users[uid] = userFoods;
    foodBox.put('users', users);

    loadFoods();
    calculateNutrition();
  }

  // ---------------- LOAD FROM HIVE ----------------
  // CHANGED: `foods` still holds ALL of the user's saved foods (every day),
  // just like before. Filtering for "today only" happens separately
  // via the `todaysFoods` getter below, and `calculateNutrition` now
  // sums only today's foods.
  void loadFoods() {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUid == null) return;

    foods.clear();

    // get all users data
    final usersData = foodBox.get('users', defaultValue: {}) as Map;

    // get current user foods
    final userFoods = usersData[currentUid] ?? [];

    foods.assignAll(
      (userFoods as List).map((e) {
        return foodModel(
          uid: e['uid'] ?? '',
          name: e['name'] ?? '',
          calories: (e['calories'] ?? 0).toDouble(),
          protein: (e['protein'] ?? 0).toDouble(),
          carbs: (e['carbs'] ?? 0).toDouble(),
          fat: (e['fat'] ?? 0).toDouble(),
          Fiber: (e['Fiber'] ?? 0).toDouble(),
          date: e['date'] != null ? DateTime.parse(e['date']) : DateTime.now(),
        );
      }).toList(),
    );

    calculateNutrition();
  }

  // ---------------- ADD FOOD ----------------
  void addFood(foodModel food) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;
    Map users = foodBox.get('users', defaultValue: {});
    List userFoods = users[currentUid] ?? [];

    userFoods.add({
      'uid': currentUid,
      'name': food.name,
      'calories': food.calories,
      'protein': food.protein,
      'carbs': food.carbs,
      'fat': food.fat,
      'Fiber': food.Fiber,
      'date': DateTime.now().toIso8601String(),
    });

    users[currentUid] = userFoods;

    foodBox.put('users', users);

    loadFoods();
  }

  // ---------------- ADD WATER ----------------
  // CHANGED: water is saved under a date-specific key so it
  // automatically starts fresh (0) each new day.
  void addWater(double water) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUid == null) return;

    totalWater.value += water;

    final todayKey = _dateKey(DateTime.now()); // ADDED
    foodBox.put(
      '${currentUid}_water_$todayKey', // CHANGED: was '${currentUid}_water'
      totalWater.value,
    );
  }

  // ---------------- CALCULATE ----------------
  // CHANGED: totals for "Today's Progress" (Calories, Protein) are now
  // calculated from `todaysFoods` only, instead of all foods ever logged.
  // This is what makes the dashboard reset to 0 for a new day,
  // while Monthly History still has access to all historical entries
  // via `foods`.
  void calculateNutrition() {
    final todays = todaysFoods; // ADDED

    totalCalories.value = todays.fold(0.0, (sum, f) => sum + f.calories);
    totalProtein.value = todays.fold(0.0, (sum, f) => sum + f.protein);
  }

  void resetDashboard() {
    foods.clear();
    foodKeys.clear();

    totalCalories.value = 0.0;
    totalProtein.value = 0.0;
    totalWater.value = 0.0;
  }

  // ADDED: returns only the foods that were logged today.
  // Used by the UI for "Recent Meals" and by calculateNutrition
  // for Today's Progress totals.
  List<foodModel> get todaysFoods {
    final now = DateTime.now();
    return foods.where((f) => _isSameDay(f.date, now)).toList();
  }

  // ---------------- RUN ESTIMATION ----------------
  // CHANGED: now subtracts the km-equivalent of steps already walked today,
  // so the "Run: X km" suggestion goes down as the user walks more.
  // Standard estimate: ~0.0008 km per step (≈1250 steps per km).
  static const double _kmPerStep = 0.0008;

  double get estimatedRunKm {
    final profileBox = Hive.box('profileBox');

    final weight = (profileBox.get('weight', defaultValue: 70) as num)
        .toDouble();

    if (weight <= 0) return 0;

    // Running burns approximately 1 kcal per kg per km
    final calorieBasedKm = totalCalories.value / weight;

    // ADDED: credit already-walked steps against the suggested run distance
    final stepsKmCredit = steps.value * _kmPerStep;

    final remaining = calorieBasedKm - stepsKmCredit;
    return remaining < 0 ? 0 : remaining;
  }

  // ADDED: reads the frozen run-km value for a specific past date from Hive.
  // Used by MonthlyHistory to show each day's locked-in run suggestion.
  // Returns 0 if no value was ever frozen for that date (e.g. before this
  // feature existed, or today—which is still live, not frozen yet).
  double getFrozenRunKm(DateTime date) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 0;

    final foodBox = Hive.box('foodBox');

    final dateKey =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    return (foodBox.get('${uid}_run_$dateKey', defaultValue: 0) as num)
        .toDouble();
  }

  double get weeklyCalories {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 6));

    final weeklyFoods = foods.where(
      (f) =>
          f.date.isAfter(weekAgo) &&
          f.date.isBefore(now.add(const Duration(days: 1))),
    );

    final total = weeklyFoods.fold(0.0, (sum, f) => sum + f.calories);

    return total;
  }

  void checkNewDay() {
    final box = Hive.box('profileBox');

    final today = DateTime.now().toString().split(' ')[0];
    final lastDay = box.get('last_day', defaultValue: '');

    if (lastDay != today) {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      _freezeRunKmForPastDate(yesterday); // CHANGED: was _freezeRunKmForDate
      box.put('last_day', today);
    }
  }

  // ADDED: recomputes and freezes run-km for a PAST date using data
  // stored in Hive, instead of live totalCalories/steps (which are
  // still 0 at app-startup, before loadFoods() has run for this session).
  void _freezeRunKmForPastDate(DateTime date) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final dateKey = _dateKey(date);

    // Sum that day's calories from stored food entries
    final usersData = foodBox.get('users', defaultValue: {}) as Map;
    final userFoods = (usersData[uid] ?? []) as List;

    double cal = 0;
    for (final f in userFoods) {
      if (f['date'] == null) continue;
      try {
        final fd = DateTime.parse(f['date']);
        if (fd.year == date.year &&
            fd.month == date.month &&
            fd.day == date.day) {
          cal += (f['calories'] ?? 0).toDouble();
        }
      } catch (_) {}
    }

    // Steps for that day
    final stepsBox = Hive.box('stepsBox');
    final steps = (stepsBox.get('${uid}_$dateKey', defaultValue: 0) as num)
        .toDouble();

    // Weight for the run-km formula
    final profileBox = Hive.box('profileBox');
    final weight = (profileBox.get('weight', defaultValue: 70) as num)
        .toDouble();
    if (weight <= 0) return;

    final calorieBasedKm = cal / weight;
    final stepsKmCredit = steps * _kmPerStep;
    final remaining = calorieBasedKm - stepsKmCredit;

    foodBox.put('${uid}_run_$dateKey', remaining < 0 ? 0 : remaining);
  }

  void saveTodayRunKm() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final foodBox = Hive.box('foodBox');

    final now = DateTime.now();
    final dateKey =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    foodBox.put('${uid}_run_$dateKey', estimatedRunKm);
  }

  // ---------------- GETTERS ----------------
  RxInt get steps => stepsController.steps;

  double get weeklyAverage => stepsController.weeklyStepsTotal / 7;
  double get weeklyCaloriesAverage {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 6));

    final weeklyFoods = foods.where(
      (f) =>
          f.date.isAfter(weekAgo) &&
          f.date.isBefore(now.add(const Duration(days: 1))),
    );

    if (weeklyFoods.isEmpty) return 0.0;

    final total = weeklyFoods.fold(0.0, (sum, f) => sum + f.calories);

    // count unique days
    final uniqueDays = weeklyFoods
        .map((f) => DateTime(f.date.year, f.date.month, f.date.day))
        .toSet()
        .length;

    return uniqueDays == 0 ? 0.0 : total / uniqueDays;
  }
}
