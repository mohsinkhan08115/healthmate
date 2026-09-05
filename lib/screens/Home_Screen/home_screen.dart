import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:healthmate/controller/home_screen_controller/home_screen_controller.dart';
import 'package:healthmate/controller/theme_controller.dart';
import 'package:healthmate/screens/bottom_navigation/dashboard_screen.dart';
import 'package:healthmate/screens/bottom_navigation/food_screen.dart';
import 'package:healthmate/screens/bottom_navigation/meals_screen.dart';
import 'package:healthmate/screens/bottom_navigation/profile_screen.dart';
import 'package:healthmate/screens/bottom_navigation/steps_screen.dart';
import 'package:healthmate/core/theme/app_colors.dart';
import 'package:healthmate/services/step_service.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  static bool _sessionHasPrompted = false;

  final BottomNavController controller = Get.put(BottomNavController());
  final ThemeController themeController = Get.find<ThemeController>();

  final List<Widget> _pages = [
    DashboardScreen(),
    StepsScreen(),
    FoodScreen(),
    MealsScreen(),
    ProfileScreen(),
  ];

  Box get _profileBox => Hive.box('profileBox');

  // Dynamic time-based greeting based on real device clock
  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return "Good morning";
    } else if (hour >= 12 && hour < 17) {
      return "Good afternoon";
    } else if (hour >= 17 && hour < 21) {
      return "Good evening";
    } else {
      return "Good night";
    }
  }

  void _checkAndShowAutoStartDialog(BuildContext context) async {
    if (_sessionHasPrompted) return;
    final hasCompleted = _profileBox.get('hasCompletedAutostart') ?? false;
    if (hasCompleted) return;
    final needsPrompt = await StepService.needsAutoStartSettings();
    if (!needsPrompt) return;

    _sessionHasPrompted = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.power_settings_new_rounded,
                  color: AppColors.emerald,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Enable Auto Start',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'To track your steps accurately in the background, HealthMate needs permission to start automatically when your phone restarts.',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Not Now'),
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
                        backgroundColor: AppColors.emerald,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Open Settings'),
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? Colors.white.withOpacity(0.06) : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final userName = _profileBox.get('name') ?? 'User';
    final formattedDate = DateFormat('MMM d, yyyy').format(DateTime.now());

    return Obx(
      () => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        // ── TOP APP BAR ──────────────────────────────────────────────────────
        appBar: AppBar(
          backgroundColor: surfaceColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 16,
          title: Row(
            children: [
              // Left: Squircle container with Emerald ECG/pulse icon
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.emerald.withOpacity(0.2) : AppColors.emeraldLightBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.monitor_heart_rounded,
                  color: AppColors.emerald,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Center: Dynamic Time-Based Greeting + User Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getTimeBasedGreeting(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Right: Date & Theme Switcher Button
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Today",
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  // Global theme toggle button
                  IconButton(
                    onPressed: () => themeController.toggleTheme(),
                    icon: Obx(
                      () => Icon(
                        themeController.isDarkMode.value
                            ? Icons.light_mode_outlined
                            : Icons.nightlight_outlined,
                        color: textPrimary,
                        size: 22,
                      ),
                    ),
                    tooltip: "Toggle Theme",
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
                ],
              ),
            ],
          ),
          shape: Border(
            bottom: BorderSide(color: borderColor, width: 1),
          ),
        ),

        // ── BODY ─────────────────────────────────────────────────────────────
        body: _pages[controller.selectedIndex.value],

        // ── BOTTOM NAVIGATION BAR ───────────────────────────────────────────
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            border: Border(
              top: BorderSide(color: borderColor, width: 1),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(context, 0, Icons.home_outlined, Icons.home_rounded, "Home"),
                  _buildNavItem(context, 1, Icons.directions_walk_outlined, Icons.directions_walk_rounded, "Steps"),
                  _buildNavItem(context, 2, Icons.restaurant_outlined, Icons.restaurant_rounded, "Food"),
                  _buildNavItem(context, 3, Icons.lunch_dining_outlined, Icons.lunch_dining_rounded, "Meals"),
                  _buildNavItem(context, 4, Icons.person_outline_rounded, Icons.person_rounded, "Profile"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData outlineIcon, IconData filledIcon, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final isSelected = controller.selectedIndex.value == index;

    return Expanded(
      child: InkWell(
        onTap: () => controller.changeIndex(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? filledIcon : outlineIcon,
              color: isSelected ? AppColors.emerald : unselectedColor,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.emerald : unselectedColor,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 4 : 0,
              height: isSelected ? 4 : 0,
              decoration: const BoxDecoration(
                color: AppColors.emerald,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
