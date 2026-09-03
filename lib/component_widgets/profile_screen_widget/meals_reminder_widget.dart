import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthmate/controller/bottom_navi_controller/profile_controller.dart';
import 'package:healthmate/services/notification_service.dart';
import 'package:hive/hive.dart';
import 'package:healthmate/core/theme/app_colors.dart';

class MealsReminderWidget extends StatelessWidget {
  MealsReminderWidget({super.key});
  final ProfileController controller = Get.find();
  final saved = Hive.box('reminderBox');
  dynamic get breakfastSaved => saved.get('breakfastReminder');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.notifications_active_outlined, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  "Meal Reminders",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(
              () => _buildReminderRow(
                context,
                Icons.wb_sunny_rounded,
                "Breakfast",
                AppColors.breakfast,
                AppColors.stepsTrack,
                "${controller.breakfastHour.value.toString().padLeft(2, '0')}:${controller.breakfastMinute.value.toString().padLeft(2, '0')}",
                controller.breakfastReminder.value,
                controller.toggleBreakfast,
                onTap: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: controller.breakfastHour.value, minute: controller.breakfastMinute.value),
                  );

                  if (pickedTime != null) {
                    controller.breakfastHour.value = pickedTime.hour;
                    controller.breakfastMinute.value = pickedTime.minute;

                    final box = Hive.box('profileBox');
                    box.put('breakfastHour', pickedTime.hour);
                    box.put('breakfastMinute', pickedTime.minute);

                    NotificationService.cancelNotification(1);

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
            const Divider(color: AppColors.border, height: 1),
            Obx(
              () => _buildReminderRow(
                context,
                Icons.lunch_dining_rounded,
                "Lunch",
                AppColors.lunch,
                AppColors.waterTrack,
                "${controller.lunchHour.value.toString().padLeft(2, '0')}:${controller.lunchMinute.value.toString().padLeft(2, '0')}",
                controller.lunchReminder.value,
                controller.toggleLunch,
                onTap: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: controller.lunchHour.value, minute: controller.lunchMinute.value),
                  );

                  if (pickedTime != null) {
                    final box = Hive.box('profileBox');

                    controller.lunchHour.value = pickedTime.hour;
                    controller.lunchMinute.value = pickedTime.minute;

                    box.put('lunchHour', pickedTime.hour);
                    box.put('lunchMinute', pickedTime.minute);

                    NotificationService.cancelNotification(2);

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
            const Divider(color: AppColors.border, height: 1),
            Obx(
              () => _buildReminderRow(
                context,
                Icons.nightlight_round,
                "Dinner",
                AppColors.dinner,
                AppColors.proteinTrack,
                "${controller.dinnerHour.value.toString().padLeft(2, '0')}:${controller.dinnerMinute.value.toString().padLeft(2, '0')}",
                controller.dinnerReminder.value,
                controller.toggleDinner,
                onTap: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: controller.dinnerHour.value, minute: controller.dinnerMinute.value),
                  );

                  if (pickedTime != null) {
                    final box = Hive.box('profileBox');

                    controller.dinnerHour.value = pickedTime.hour;
                    controller.dinnerMinute.value = pickedTime.minute;

                    box.put('dinnerHour', pickedTime.hour);
                    box.put('dinnerMinute', pickedTime.minute);

                    NotificationService.cancelNotification(3);

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
      ),
    );
  }

  Widget _buildReminderRow(
    BuildContext context,
    IconData icon,
    String text,
    Color color,
    Color trackColor,
    String time,
    bool value,
    Function(bool) onchanged, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: trackColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        time,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onchanged,
        activeThumbColor: AppColors.primary,
        activeTrackColor: AppColors.primary.withOpacity(0.3),
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: Colors.grey.shade200,
      ),
    );
  }
}
