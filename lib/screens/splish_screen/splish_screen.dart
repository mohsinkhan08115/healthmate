import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthmate/core/theme/app_colors.dart';
import 'package:healthmate/screens/auth_screens/wrapper.dart';

class SplishScreen extends StatefulWidget {
  const SplishScreen({super.key});

  @override
  State<SplishScreen> createState() => _SplishScreenState();
}

class _SplishScreenState extends State<SplishScreen>
    with SingleTickerProviderStateMixin {
  double opacity = 0;

  @override
  void initState() {
    super.initState();

    // Animation start
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        opacity = 1;
      });
    });

    // Navigation
    Timer(const Duration(seconds: 3), () {
      Get.off(() => const Wrapper());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.screenGradient),
        child: AnimatedOpacity(
          duration: const Duration(seconds: 2),
          opacity: opacity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  "assets/images/step_counter_img.jpg",
                  height: 80,
                ),
              ),

              // App Name
              const Text(
                "HealthMate",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.background,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Track your health daily",
                style: TextStyle(fontSize: 14, color: AppColors.background),
              ),

              const SizedBox(height: 40),

              // Loader
              const CircularProgressIndicator(color: AppColors.background),
            ],
          ),
        ),
      ),
    );
  }
}
