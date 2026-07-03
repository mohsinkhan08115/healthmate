import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:healthmate/services/notification_service.dart';

class ProfileController extends GetxController {
  // ---------------- PROFILE ----------------
  RxString profileImage = "".obs;
  RxString name = "".obs;
  RxInt age = 0.obs;
  RxDouble weight = 0.0.obs;
  RxDouble height = 0.0.obs;
  RxInt breakfastHour = 9.obs;
  RxInt breakfastMinute = 0.obs;

  RxInt lunchHour = 13.obs;
  RxInt lunchMinute = 30.obs;

  RxInt dinnerHour = 19.obs;
  RxInt dinnerMinute = 30.obs;

  // ---------------- GOALS ----------------
  RxInt stepGoal = 10000.obs;
  RxDouble calorieGoal = 2000.0.obs;
  RxDouble proteinGoal = 100.0.obs;
  RxInt waterGoal = 8.obs;

  // ---------------- REMINDERS ----------------
  RxBool breakfastReminder = false.obs;
  RxBool lunchReminder = false.obs;
  RxBool dinnerReminder = false.obs;

  Box get _box => Hive.box('profileBox');

  // ---------------- INIT ----------------
  // ---------------- INIT ----------------
  @override
  void onInit() {
    super.onInit();

    // CHANGED: moved loading logic into reusable loadProfile()
    loadProfile();

    breakfastHour.value = _box.get('breakfastHour', defaultValue: 9);
    breakfastMinute.value = _box.get('breakfastMinute', defaultValue: 0);

    lunchHour.value = _box.get('lunchHour', defaultValue: 12);
    lunchMinute.value = _box.get('lunchMinute', defaultValue: 30);

    dinnerHour.value = _box.get('dinnerHour', defaultValue: 19);
    dinnerMinute.value = _box.get('dinnerMinute', defaultValue: 30);

    breakfastReminder.value = _box.get('breakfast', defaultValue: false);
    lunchReminder.value = _box.get('lunch', defaultValue: false);
    dinnerReminder.value = _box.get('dinner', defaultValue: false);

    _rescheduleAll();
  }

  // ADDED: re-loadable profile/goals loading logic. Call this again
  // after signup (when Hive data is written) to refresh the in-memory
  // values, since ProfileController.onInit() already ran at app startup
  // before the user signed up.
  void loadProfile() {
    name.value = _box.get('name', defaultValue: '');
    age.value = _box.get('age', defaultValue: 0);
    weight.value = (_box.get('weight', defaultValue: 0.0) as num).toDouble();
    height.value = (_box.get('height', defaultValue: 0.0) as num).toDouble();
    profileImage.value = _box.get('profileImage', defaultValue: '');

    stepGoal.value = _box.get('steps', defaultValue: 10000);
    calorieGoal.value = (_box.get('calories', defaultValue: 2000.0) as num)
        .toDouble();
    proteinGoal.value = (_box.get('protein', defaultValue: 100.0) as num)
        .toDouble();
    waterGoal.value = _box.get('water', defaultValue: 8);
  }

  // ---------------- PROFILE UPDATE ----------------
  void updateProfile({
    String? newName,
    int? newAge,
    double? newWeight,
    double? newHeight,
  }) {
    if (newName != null) {
      name.value = newName;
      _box.put('name', newName);
    }
    if (newAge != null) {
      age.value = newAge;
      _box.put('age', newAge);
    }
    if (newWeight != null) {
      weight.value = newWeight;
      _box.put('weight', newWeight);
    }
    if (newHeight != null) {
      height.value = newHeight;
      _box.put('height', newHeight);
    }
  }

  // ---------------- GOALS UPDATE ----------------
  void updateGoals({
    int? steps,
    double? calories,
    double? protein,
    int? water,
  }) {
    if (steps != null) {
      stepGoal.value = steps;
      _box.put('steps', steps);
    }
    if (calories != null) {
      calorieGoal.value = calories;
      _box.put('calories', calories);
    }
    if (protein != null) {
      proteinGoal.value = protein;
      _box.put('protein', protein);
    }
    if (water != null) {
      waterGoal.value = water;
      _box.put('water', water);
    }
  }

  // ---------------- TOGGLE BREAKFAST ----------------
  void toggleBreakfast(bool value) {
    breakfastReminder.value = value;
    _box.put('breakfast', value);

    if (value) {
      NotificationService.scheduleNotification(
        id: 1,
        title: "Breakfast Reminder",
        body: "Don't forget your breakfast 🍳",
        hour: 9,
        minute: 0,
      );
    } else {
      NotificationService.cancelNotification(1);
    }
  }

  // ---------------- TOGGLE LUNCH ----------------
  void toggleLunch(bool value) {
    lunchReminder.value = value;
    _box.put('lunch', value);

    if (value) {
      final hour = _box.get('lunchHour', defaultValue: 13);
      final minute = _box.get('lunchMinute', defaultValue: 30);

      NotificationService.scheduleNotification(
        id: 2,
        title: "Lunch Reminder",
        body: "Time for lunch 🍱",
        hour: hour,
        minute: minute,
      );
    } else {
      NotificationService.cancelNotification(2);
    }
  }

  // ---------------- TOGGLE DINNER ----------------
  void toggleDinner(bool value) {
    dinnerReminder.value = value;
    _box.put('dinner', value);

    if (value) {
      NotificationService.scheduleNotification(
        id: 3,
        title: "Dinner Reminder",
        body: "Dinner time 🍽️",
        hour: 19,
        minute: 30,
      );
    } else {
      NotificationService.cancelNotification(3);
    }
  }

  // ---------------- RESCHEDULE ON APP OPEN ----------------
  void _rescheduleAll() {
    if (breakfastReminder.value) {
      NotificationService.scheduleNotification(
        id: 1,
        title: "Breakfast Reminder",
        body: "Don't forget your breakfast 🍳",
        hour: breakfastHour.value,
        minute: breakfastMinute.value,
      );
    }

    if (lunchReminder.value) {
      NotificationService.scheduleNotification(
        id: 2,
        title: "Lunch Reminder",
        body: "Time for lunch 🍱",
        hour: lunchHour.value,
        minute: lunchMinute.value,
      );
    }

    if (dinnerReminder.value) {
      NotificationService.scheduleNotification(
        id: 3,
        title: "Dinner Reminder",
        body: "Dinner time 🍽️",
        hour: dinnerHour.value,
        minute: dinnerMinute.value,
      );
    }
  }
}
