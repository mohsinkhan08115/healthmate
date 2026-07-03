import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthmate/component_widgets/profile_screen_widget/daily_goals.dart';
import 'package:healthmate/component_widgets/profile_screen_widget/meals_reminder_widget.dart';
import 'package:healthmate/component_widgets/profile_screen_widget/your_profile_widget.dart';
import 'package:healthmate/controller/bottom_navi_controller/dashboard_controller.dart';
import 'package:healthmate/screens/bottom_navigation/settings.dart';
//import 'package:intl/intl.dart';

class ProfileScreen extends StatelessWidget {
  final DashboardController controller = Get.find();
  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            YourProfileWidget(),
            SizedBox(height: 15),
            Obx(
              () => DailyGoals(
                steps: controller.steps.value.toDouble(),
                calouies: controller.totalCalories.value,
                protein: controller.totalProtein.value,
                water: controller.totalWater.value,
              ),
            ),
            SizedBox(height: 15),
            MealsReminderWidget(),
            SizedBox(height: 15),
            // YourStats(),
            Card(
              elevation: 10,
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text("App Settings"),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Get.to(() => Settings());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
