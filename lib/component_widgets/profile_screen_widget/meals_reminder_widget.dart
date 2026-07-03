import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthmate/controller/bottom_navi_controller/profile_controller.dart';
import 'package:healthmate/services/notification_service.dart';
import 'package:hive/hive.dart';

class MealsReminderWidget extends StatelessWidget {
  MealsReminderWidget({super.key});
  final ProfileController controller = Get.find();
  final saved = Hive.box('reminderBox');
  dynamic get breakfastSaved => saved.get('breakfastReminder');
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Column(
        children: [
          Row(children: [Icon(Icons.notifications), Text("Meal Reminders")]),
          Obx(
            () => getListTile(
              Icons.sunny_snowing,
              "BreakFast",
              subtitleWidget: Obx(
                () => Text(
                  "${controller.breakfastHour.value.toString().padLeft(2, '0')}"
                  ":"
                  "${controller.breakfastMinute.value.toString().padLeft(2, '0')}",
                ),
              ),
              controller.breakfastReminder.value,
              controller.toggleBreakfast,
              onTap: () async {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 9, minute: 30),
                );

                if (pickedTime != null) {
                  controller.breakfastHour.value = pickedTime.hour;
                  controller.breakfastMinute.value = pickedTime.minute;

                  final box = Hive.box('profileBox');
                  box.put('breakfastHour', pickedTime.hour);
                  box.put('breakfastMinute', pickedTime.minute);

                  // 🔥 cancel old notification first
                  NotificationService.cancelNotification(1);

                  // 🔥 schedule new one
                  if (controller.breakfastReminder.value) {
                    NotificationService.scheduleNotification(
                      id: 1,
                      title: "Breakfast Reminder",
                      body: "Time for Breakfast 🍳",
                      hour: pickedTime.hour,
                      minute: pickedTime.minute,
                    );
                  }
                }
              },
            ),
          ),
          Obx(
            () => getListTile(
              Icons.sunny,
              "Lunch",
              subtitleWidget: Obx(
                () => Text(
                  "${controller.lunchHour.value.toString().padLeft(2, '0')}"
                  ":"
                  "${controller.lunchMinute.value.toString().padLeft(2, '0')}",
                ),
              ),
              controller.lunchReminder.value,
              controller.toggleLunch,
              onTap: () async {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 12, minute: 30),
                );

                if (pickedTime != null) {
                  final box = Hive.box('profileBox');

                  controller.lunchHour.value = pickedTime.hour;
                  controller.lunchMinute.value = pickedTime.minute;

                  box.put('lunchHour', pickedTime.hour);
                  box.put('lunchMinute', pickedTime.minute);

                  NotificationService.cancelNotification(2); // 🔥 important

                  if (controller.lunchReminder.value) {
                    NotificationService.scheduleNotification(
                      id: 2,
                      title: "Lunch Reminder",
                      body: "Time for lunch 🍱",
                      hour: pickedTime.hour,
                      minute: pickedTime.minute,
                    );
                  }
                }
              },
            ),
          ),
          Obx(
            () => getListTile(
              Icons.nightlight,
              "Dinner",
              subtitleWidget: Obx(
                () => Text(
                  "${controller.dinnerHour.value.toString().padLeft(2, '0')}"
                  ":"
                  "${controller.dinnerMinute.value.toString().padLeft(2, '0')}",
                ),
              ),
              controller.dinnerReminder.value,
              controller.toggleDinner,
              onTap: () async {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 19, minute: 30),
                );

                if (pickedTime != null) {
                  final box = Hive.box('profileBox');

                  controller.dinnerHour.value = pickedTime.hour;
                  controller.dinnerMinute.value = pickedTime.minute;

                  box.put('dinnerHour', pickedTime.hour);
                  box.put('dinnerMinute', pickedTime.minute);

                  NotificationService.cancelNotification(3); // 🔥 important

                  if (controller.dinnerReminder.value) {
                    NotificationService.scheduleNotification(
                      id: 3,
                      title: "Dinner Reminder",
                      body: "Time for Dinner 🍽️",
                      hour: pickedTime.hour,
                      minute: pickedTime.minute,
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget getListTile(
    IconData icon,
    String text,
    bool value,
    Function(bool) onchanged, {
    VoidCallback? onTap,
    Widget? subtitleWidget,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: ListTile(
        onTap: onTap, // 👈 ADD THIS
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icon),
        title: Text(text),
        subtitle: subtitleWidget,
        trailing: Switch(value: value, onChanged: onchanged),
      ),
    );
  }
}
