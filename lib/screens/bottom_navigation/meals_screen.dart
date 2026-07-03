import 'package:flutter/material.dart';
import 'package:healthmate/component_widgets/meals_widgets/breakfast_widget.dart';
import 'package:healthmate/core/theme/app_colors.dart';
import 'package:healthmate/models/meals_model.dart';

class MealsScreen extends StatelessWidget {
  const MealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Card(
              elevation: 10,
              child: Container(
                height: 125,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppColors.screenGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: .center,
                  crossAxisAlignment: .start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(
                        "Meal Suggestions",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(
                        "Healthy meal ideas for every time of day",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),

                    // SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            SizedBox(height: 25),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.green,
              ),
              child: MealSectionWidget(
                txt: 'Breakfast',
                subtxt: 'Start your day right',
                icon: Icons.wb_sunny,
                meals: [
                  Meal(
                    icon: Icons.icecream,
                    title: 'Greek Yogurt Parfait',
                    subtitle: 'Yogurt, granola, berries & honey',
                    calories: 280,
                    protein: 18,
                  ),
                  Meal(
                    icon: Icons.food_bank,
                    title: 'Avocado Toast',
                    subtitle: 'Whole grain bread, avocado, egg',
                    calories: 320,
                    protein: 12,
                  ),
                  Meal(
                    icon: Icons.local_drink,
                    title: 'Banana, protein powder, almond milk',
                    subtitle: 'Whole grain bread, avocado, egg',
                    calories: 250,
                    protein: 25,
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.amber,
              ),
              child: MealSectionWidget(
                txt: 'Lunch',
                subtxt: 'Fuel your afternoon',
                icon: Icons.lunch_dining,
                meals: [
                  Meal(
                    icon: Icons.rice_bowl,
                    title: 'Chicken Quinoa Bowl',
                    subtitle: 'Grilled chicken, quinoa, veggies',
                    calories: 480,
                    protein: 38,
                  ),
                  Meal(
                    icon: Icons.rice_bowl,
                    title: 'Mediterranean Wrap',
                    subtitle: 'Hummus, falafel, fresh veggies',
                    calories: 420,
                    protein: 28,
                  ),
                  Meal(
                    icon: Icons.rice_bowl,
                    title: 'Salmon Salad',
                    subtitle: 'Grilled salmon, mixed greens, dressing',
                    calories: 450,
                    protein: 35,
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.redAccent,
              ),
              child: MealSectionWidget(
                txt: 'Dinner',
                subtxt: 'End your day with nutrition',
                icon: Icons.nightlight_round,
                meals: [
                  Meal(
                    icon: Icons.local_dining,
                    title: 'Stir-Fry Rice Bowl',
                    subtitle: 'Chicken, vegetables, brown rice',
                    calories: 520,
                    protein: 32,
                  ),
                  Meal(
                    icon: Icons.local_dining,
                    title: 'Grilled Steak',
                    subtitle: 'Lean steak, sweet potato, broccoli',
                    calories: 580,
                    protein: 45,
                  ),
                  Meal(
                    icon: Icons.local_dining,
                    title: 'Pasta Primavera',
                    subtitle: 'Whole wheat pasta, vegetables, sauce',
                    calories: 640,
                    protein: 22,
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Card(
              elevation: 5,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  gradient: AppColors.buttonGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: .center,
                  crossAxisAlignment: .start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.white),
                        Text(
                          "Nutrition Tips",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      " ✓ Aim for 20-30g of protein per meal",
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      " ✓ Include colorful vegetables in every meal",
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      " ✓ Stay hydrated throughout the day",
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      " ✓ Eat within 1-2 hours after waking up",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
