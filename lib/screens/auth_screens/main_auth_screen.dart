import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthmate/component_widgets/button_widgets.dart';
import 'package:healthmate/core/theme/app_colors.dart';
import 'package:healthmate/screens/auth_screens/login_screen.dart';
import 'package:healthmate/screens/auth_screens/signup_screen.dart';

class MainAuthScreen extends StatefulWidget {
  const MainAuthScreen({super.key});

  @override
  State<MainAuthScreen> createState() => _MainAuthScreenState();
}

class _MainAuthScreenState extends State<MainAuthScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.15)
        : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(color: backgroundColor),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 140),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                "Are You Ready For Fit YourSelf !",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Divider(
                color: borderColor,
                thickness: 1,
                indent: 30,
                endIndent: 30,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30.0, vertical: 16.0),
                child: Text(
                  "Tracking your daily steps helps you stay active and monitor your physical activity. Walking regularly improves heart health, burns calories, and boosts mood. Aim for a daily step goal to build a consistent and healthy routine.",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Custombutton(
                        text: "Sign In",
                        onPressed: () {
                          Get.to(() => AuthScreen());
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Custombutton(
                        text: "Register",
                        onPressed: () {
                          Get.to(() => RegisterScreen());
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
