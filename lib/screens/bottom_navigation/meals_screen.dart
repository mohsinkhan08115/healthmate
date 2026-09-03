import 'package:flutter/material.dart';
import 'package:healthmate/component_widgets/meals_widgets/breakfast_widget.dart';
import 'package:healthmate/core/theme/app_colors.dart';
import 'package:healthmate/models/meals_model.dart';

class MealsScreen extends StatelessWidget {
  const MealsScreen({super.key});

  Widget _buildTipRow(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.steps, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Header Text
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Meal Suggestions",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Healthy meal ideas for every time of day",
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            MealSectionWidget(
              txt: 'Breakfast',
              subtxt: 'Start your day right',
              icon: Icons.wb_sunny_rounded,
              meals: [
                Meal(
                  icon: Icons.icecream_rounded,
                  title: 'Greek Yogurt Parfait',
                  subtitle: 'Yogurt, granola, berries & honey',
                  calories: 280,
                  protein: 18,
                ),
                Meal(
                  icon: Icons.breakfast_dining_rounded,
                  title: 'Avocado Toast',
                  subtitle: 'Whole grain bread, avocado, egg',
                  calories: 320,
                  protein: 12,
                ),
                Meal(
                  icon: Icons.local_drink_rounded,
                  title: 'Protein Smoothie',
                  subtitle: 'Banana, protein powder, almond milk',
                  calories: 250,
                  protein: 25,
                ),
              ],
            ),
            const SizedBox(height: 4),

            MealSectionWidget(
              txt: 'Lunch',
              subtxt: 'Fuel your afternoon',
              icon: Icons.lunch_dining_rounded,
              meals: [
                Meal(
                  icon: Icons.rice_bowl_rounded,
                  title: 'Chicken Quinoa Bowl',
                  subtitle: 'Grilled chicken, quinoa, veggies',
                  calories: 480,
                  protein: 38,
                ),
                Meal(
                  icon: Icons.rice_bowl_rounded,
                  title: 'Mediterranean Wrap',
                  subtitle: 'Hummus, falafel, fresh veggies',
                  calories: 420,
                  protein: 28,
                ),
                Meal(
                  icon: Icons.rice_bowl_rounded,
                  title: 'Salmon Salad',
                  subtitle: 'Grilled salmon, mixed greens, dressing',
                  calories: 450,
                  protein: 35,
                ),
              ],
            ),
            const SizedBox(height: 4),

            MealSectionWidget(
              txt: 'Dinner',
              subtxt: 'End your day with nutrition',
              icon: Icons.nightlight_round,
              meals: [
                Meal(
                  icon: Icons.local_dining_rounded,
                  title: 'Stir-Fry Rice Bowl',
                  subtitle: 'Chicken, vegetables, brown rice',
                  calories: 520,
                  protein: 32,
                ),
                Meal(
                  icon: Icons.local_dining_rounded,
                  title: 'Grilled Steak',
                  subtitle: 'Lean steak, sweet potato, broccoli',
                  calories: 580,
                  protein: 45,
                ),
                Meal(
                  icon: Icons.local_dining_rounded,
                  title: 'Pasta Primavera',
                  subtitle: 'Whole wheat pasta, vegetables, sauce',
                  calories: 640,
                  protein: 22,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Nutrition Tips Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Container(
                width: double.infinity,
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
                    Row(
                      children: const [
                        Icon(Icons.star_rounded, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Nutrition Tips",
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTipRow("Aim for 20-30g of protein per meal"),
                    _buildTipRow("Include colorful vegetables in every meal"),
                    _buildTipRow("Stay hydrated throughout the day"),
                    _buildTipRow("Eat within 1-2 hours after waking up"),
                  ],
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
