import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthmate/controller/bottom_navi_controller/dashboard_controller.dart';
import 'package:healthmate/core/theme/app_colors.dart';
import 'package:healthmate/models/food_model.dart';

class QuickAddScreen extends StatelessWidget {
  const QuickAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Padding(
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Quick Add",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.9,
              children: [
                QuickItem(
                  "assets/images/Burger.png",
                  "Beef Burger",
                  540,
                  25.0,
                  41.0,
                  31.0,
                  2.0,
                  AppColors.waterTrack,
                  AppColors.water,
                ),
                QuickItem(
                  "assets/images/rice.png",
                  "White Rice",
                  130,
                  2.7,
                  28.2,
                  0.3,
                  0.4,
                  AppColors.proteinTrack,
                  AppColors.protein,
                ),
                QuickItem(
                  "assets/images/fried-egg.png",
                  "Fried Egg",
                  90,
                  6.3,
                  0.4,
                  7.0,
                  0.0,
                  AppColors.caloriesTrack,
                  AppColors.calories,
                ),
                QuickItem(
                  "assets/images/white-bread.png",
                  "White Bread",
                  80,
                  2.7,
                  14.0,
                  1.0,
                  0.8,
                  AppColors.primarySurface,
                  AppColors.primarySoft,
                ),
                QuickItem(
                  "assets/images/banana.png",
                  "Banana",
                  105,
                  1.3,
                  27.0,
                  0.3,
                  3.1,
                  AppColors.stepsTrack,
                  AppColors.steps,
                ),
                QuickItem(
                  "assets/images/milk.png",
                  "Milk (240ml)",
                  149,
                  7.7,
                  12.0,
                  8.0,
                  0.0,
                  AppColors.waterTrack,
                  AppColors.water,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget QuickItem(
  String imagePath,
  String label,
  double calories,
  double protein,
  double carbs,
  double fat,
  double fiber,
  Color bgColor,
  Color textColor,
) {
  Color trackColor = AppColors.caloriesTrack;

  final lowerLabel = label.toLowerCase();
  if (lowerLabel.contains("banana") || lowerLabel.contains("bread")) {
    trackColor = AppColors.primarySurface;
  } else if (lowerLabel.contains("rice")) {
    trackColor = AppColors.proteinTrack;
  } else if (lowerLabel.contains("milk") || lowerLabel.contains("burger")) {
    trackColor = AppColors.waterTrack;
  } else if (lowerLabel.contains("egg")) {
    trackColor = AppColors.stepsTrack; // Use light green for egg/breakfast
  }

  return GestureDetector(
    onTap: () {
      final DashboardController controllers = Get.find<DashboardController>();
      final newFood = foodModel(
        uid: "",
        name: label,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        Fiber: fiber,
        date: DateTime.now(),
      );
      controllers.addFood(newFood);
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: trackColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "${calories.toStringAsFixed(0)} kcal",
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.calories,
                  ),
                ),
                Text(
                  "P: ${protein.toStringAsFixed(0)}g",
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.protein,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

