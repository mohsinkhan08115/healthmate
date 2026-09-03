import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthmate/component_widgets/profile_screen_widget/daily_goals.dart';
import 'package:healthmate/component_widgets/profile_screen_widget/meals_reminder_widget.dart';
import 'package:healthmate/component_widgets/profile_screen_widget/your_profile_widget.dart';
import 'package:healthmate/controller/bottom_navi_controller/dashboard_controller.dart';
import 'package:healthmate/screens/bottom_navigation/settings.dart';
import 'package:healthmate/core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  final DashboardController controller = Get.find();
  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            YourProfileWidget(),
            const SizedBox(height: 12),
            Obx(
              () => DailyGoals(
                steps: controller.steps.value.toDouble(),
                calouies: controller.totalCalories.value,
                protein: controller.totalProtein.value,
                water: controller.totalWater.value,
              ),
            ),
            const SizedBox(height: 12),
            MealsReminderWidget(),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.settings_outlined, color: AppColors.primary, size: 20),
                  ),
                  title: const Text(
                    "App Settings",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textSecondary, size: 14),
                  onTap: () {
                    Get.to(() => Settings());
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
