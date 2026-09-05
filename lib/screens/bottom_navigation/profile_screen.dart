import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthmate/component_widgets/profile_screen_widget/daily_goals.dart';
import 'package:healthmate/component_widgets/profile_screen_widget/meals_reminder_widget.dart';
import 'package:healthmate/component_widgets/profile_screen_widget/your_profile_widget.dart';
import 'package:healthmate/controller/bottom_navi_controller/dashboard_controller.dart';
import 'package:healthmate/screens/bottom_navigation/settings.dart';
import 'package:healthmate/core/theme/app_colors.dart';
import 'package:healthmate/core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  final DashboardController controller = Get.find();
  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.06) : AppColors.lightBorder,
                    width: 1,
                  ),
                  boxShadow: AppTheme.cardShadow(context),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF00A86B).withOpacity(0.15) : const Color(0xFFE8F8F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.settings_outlined,
                      color: isDark ? const Color(0xFF00A86B) : AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    "App Settings",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    size: 14,
                  ),
                  onTap: () {
                    Get.to(() => const Settings());
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
