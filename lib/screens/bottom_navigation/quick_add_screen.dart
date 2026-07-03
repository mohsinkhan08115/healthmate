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
    // final FoodController controller = Get.find<FoodController>();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(blurRadius: 5, color: AppColors.surface)],
      ),
      child: Column(
        children: [
          Text(
            "Quick Add",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 30),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              QuickItem(
                "assets/images/Burger.png",
                "Beef Burger",
                540, // Calories
                25.0, // Protein (g)
                41.0, // Carbs (g)
                31.0, // Fat (g)
                2.0, // Fiber (g)
                AppColors.waterTrack,
                AppColors.water,
              ),

              QuickItem(
                "assets/images/rice.png",
                "White Rice 100g",
                130, // Calories
                2.7, // Protein (g)
                28.2, // Carbs (g)
                0.3, // Fat (g)
                0.4, // Fiber (g)
                AppColors.proteinTrack,
                AppColors.protein,
              ),

              QuickItem(
                "assets/images/fried-egg.png",
                "Fried Egg",
                90, // Calories
                6.3, // Protein (g)
                0.4, // Carbs (g)
                7.0, // Fat (g)
                0.0, // Fiber (g)
                AppColors.caloriesTrack,
                AppColors.calories,
              ),

              QuickItem(
                "assets/images/white-bread.png",
                "White Bread",
                80, // Calories (1 slice)
                2.7, // Protein (g)
                14.0, // Carbs (g)
                1.0, // Fat (g)
                0.8, // Fiber (g)
                AppColors.primarySurface,
                AppColors.primarySoft,
              ),

              QuickItem(
                "assets/images/banana.png",
                "Banana",
                105, // Calories
                1.3, // Protein (g)
                27.0, // Carbs (g)
                0.3, // Fat (g)
                3.1, // Fiber (g)
                AppColors.stepsTrack,
                AppColors.steps,
              ),

              QuickItem(
                "assets/images/milk.png",
                "Milk (240 ml)",
                149, // Calories
                7.7, // Protein (g)
                12.0, // Carbs (g)
                8.0, // Fat (g)
                0.0, // Fiber (g)
                AppColors.waterTrack,
                AppColors.water,
              ),
            ],
          ),
        ],
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
  return GestureDetector(
    onTap: () {
      final DashboardController controllers = Get.find<DashboardController>();

      var uid;
      final newFood = foodModel(
        uid: "$uid",
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
      width: 200,
      height: 200,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: bgColor,
        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 30, width: 30),
          SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 5),

          // 👇 Nutrition info
          Text("Cal: $calories", style: TextStyle(fontSize: 10)),

          Text("P: $protein | C: $carbs", style: TextStyle(fontSize: 10)),

          Text("F: $fat | Fi: $fiber", style: TextStyle(fontSize: 10)),
        ],
      ),
    ),
  );
}
