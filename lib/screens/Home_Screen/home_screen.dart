import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart'; // New import
import 'package:healthmate/controller/home_screen_controller/home_screen_controller.dart';
import 'package:healthmate/screens/bottom_navigation/dashboard_screen.dart';
import 'package:healthmate/screens/bottom_navigation/food_screen.dart';
import 'package:healthmate/screens/bottom_navigation/meals_screen.dart';
import 'package:healthmate/screens/bottom_navigation/profile_screen.dart';
import 'package:healthmate/screens/bottom_navigation/steps_screen.dart';
import 'package:healthmate/core/theme/app_colors.dart';
import 'package:healthmate/services/step_service.dart';


// ignore: must_be_immutable
class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  static bool _sessionHasPrompted = false;

  final BottomNavController controller = Get.put(BottomNavController());

  DateTime currentDate = DateTime.now();

  final List<Widget> _pages = [
    DashboardScreen(),
    StepsScreen(),
    FoodScreen(),
    MealsScreen(),
    ProfileScreen(),
  ];

  // Changed: removed FirebaseAuth user + getUserData() (was reading from
  // Firestore, but the name is actually saved in Hive's profileBox)
  Box get _profileBox => Hive.box('profileBox');

  void _checkAndShowAutoStartDialog(BuildContext context) async {
    // 1. Don't prompt again in the same session
    if (_sessionHasPrompted) return;

    // 2. If the user has already completed the flow, it's no longer required
    final hasCompleted = _profileBox.get('hasCompletedAutostart') ?? false;
    if (hasCompleted) return;

    // 3. Only show if the device needs Auto Start settings
    final needsPrompt = await StepService.needsAutoStartSettings();
    if (!needsPrompt) return;

    // Set the session flag immediately to prevent duplicate dialogs in the same session
    _sessionHasPrompted = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.power_settings_new_rounded,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Enable Auto Start',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'To track your steps accurately in the background, HealthMate needs permission to start automatically when your phone restarts. Please enable Auto Start in settings.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _profileBox.put('hasCompletedAutostart', true);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Not Now',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _profileBox.put('hasCompletedAutostart', true);
                        StepService.openAutoStartSettings();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Open Settings',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowAutoStartDialog(context);
    });
    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 16,
          title: Row(
            children: [
              Container(
                height: 36,
                width: 36,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset(
                  "assets/images/lifeline.png",
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Hello, ${_profileBox.get('name') ?? 'User'}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Text(
                      "Your Health Companion",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Today",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${currentDate.day}/${currentDate.month}/${currentDate.year}",
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          shape: const Border(
            bottom: BorderSide(color: AppColors.border, width: 1),
          ),
        ),

        body: _pages[controller.selectedIndex.value],

        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            currentIndex: controller.selectedIndex.value,
            onTap: controller.changeIndex,
            selectedLabelStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.normal,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.dashboard_outlined),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.dashboard_rounded),
                ),
                label: "Dashboard",
              ),

              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.directions_walk_outlined),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.directions_walk_rounded),
                ),
                label: "Steps",
              ),

              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.restaurant_outlined),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.restaurant_rounded),
                ),
                label: "Food",
              ),

              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.lunch_dining_outlined),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.lunch_dining_rounded),
                ),
                label: "Meals",
              ),

              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.person_outline),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.person),
                ),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
