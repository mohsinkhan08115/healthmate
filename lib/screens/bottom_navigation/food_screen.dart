import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthmate/component_widgets/food_tile_avatar.dart';
import 'package:healthmate/controller/bottom_navi_controller/add_food_image.dart';
import 'package:healthmate/controller/bottom_navi_controller/dashboard_controller.dart';
import 'package:healthmate/core/theme/app_colors.dart';
import 'package:healthmate/core/theme/app_theme.dart';
import 'package:healthmate/screens/bottom_navigation/add_food_manually.dart';
import 'package:healthmate/screens/bottom_navigation/quick_add_screen.dart';
import 'package:intl/intl.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  final DashboardController controller = Get.find<DashboardController>();

  final double _calGoal = 2000;
  final double _proteinGoal = 75;

  void showAddOptionsSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddFoodManually(),
    );
  }

  void showImagePickerSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddFoodImage(),
    );
  }

  // ── Today's Nutrition Card ───────────────────────────────
  Widget _buildNutritionCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.06)
        : AppColors.lightBorder;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    return Obx(() {
      final foods = controller.todaysFoods;
      final double totalCal = foods.fold(0, (s, f) => s + (f.calories));
      final double totalProtein = foods.fold(0, (s, f) => s + (f.protein));
      final double totalCarbs = foods.fold(0, (s, f) => s + (f.carbs));
      final double totalFat = foods.fold(0, (s, f) => s + (f.fat));
      final double totalFiber = foods.fold(0, (s, f) => s + (f.Fiber));

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: AppTheme.cardShadow(context),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Today's Nutrition",
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _NutritionBigTile(
                      label: "Calories",
                      value: totalCal.toStringAsFixed(0),
                      goal: "of ${_calGoal.toInt()} kcal",
                      color: AppColors.calories,
                      trackColor: AppColors.calories.withOpacity(
                        isDark ? 0.2 : 0.12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NutritionBigTile(
                      label: "Protein",
                      value: "${totalProtein.toStringAsFixed(0)}g",
                      goal: "of ${_proteinGoal.toInt()}g",
                      color: AppColors.protein,
                      trackColor: AppColors.protein.withOpacity(
                        isDark ? 0.2 : 0.12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: borderColor, height: 1),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NutritionSmallTile(
                    label: "Carbs",
                    value: "${totalCarbs.toStringAsFixed(0)}g",
                  ),
                  _NutritionSmallTile(
                    label: "Fat",
                    value: "${totalFat.toStringAsFixed(0)}g",
                  ),
                  _NutritionSmallTile(
                    label: "Fiber",
                    value: "${totalFiber.toStringAsFixed(0)}g",
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.06)
        : AppColors.lightBorder;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Food Logger",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Track your nutrition and stay healthy",
                    style: TextStyle(fontSize: 13, color: textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Log your Food buttons card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1),
                  boxShadow: AppTheme.cardShadow(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Add Food / Water",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: showAddOptionsSheet,
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text(
                              "Add Manually",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: showImagePickerSheet,
                            icon: const Icon(
                              Icons.camera_alt_rounded,
                              size: 18,
                            ),
                            label: const Text(
                              "Scan Food",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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

            // Today's Nutrition Card
            _buildNutritionCard(context),

            // Quick Add widget
            const QuickAddScreen(),

            // Today's Meals Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  Text(
                    "Today's Meals",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Today's Meals dynamic list
            Obx(() {
              final todaysMeals = controller.todaysFoods;

              if (todaysMeals.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 32,
                    ),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 1),
                      boxShadow: AppTheme.cardShadow(context),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.restaurant_menu_rounded,
                          size: 36,
                          color: textSecondary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "No meals logged yet",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Start adding your meals to track your nutrition.",
                          style: TextStyle(fontSize: 11, color: textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: todaysMeals.length,
                  itemBuilder: (context, index) {
                    final food = todaysMeals[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor, width: 1),
                        boxShadow: AppTheme.cardShadow(context),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        leading: FoodTileAvatar(foodName: food.name),
                        title: Text(
                          food.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        subtitle: Wrap(
                          spacing: 6,
                          runSpacing: 2,
                          children: [
                            Text(
                              "${food.calories.toStringAsFixed(0)} kcal",
                              style: const TextStyle(
                                color: AppColors.calories,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "P: ${food.protein.toStringAsFixed(0)}g",
                              style: const TextStyle(
                                color: AppColors.protein,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              "C: ${food.carbs.toStringAsFixed(0)}g",
                              style: const TextStyle(
                                color: AppColors.water,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              "F: ${food.fat.toStringAsFixed(0)}g",
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateFormat('hh:mm a').format(food.date),
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: AppColors.calories,
                                size: 20,
                              ),
                              onPressed: () {
                                final originalIndex = controller.foods.indexOf(
                                  food,
                                );
                                if (originalIndex != -1) {
                                  controller.deleteFood(originalIndex);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _NutritionBigTile extends StatelessWidget {
  final String label;
  final String value;
  final String goal;
  final Color color;
  final Color trackColor;

  const _NutritionBigTile({
    required this.label,
    required this.value,
    required this.goal,
    required this.color,
    required this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(goal, style: TextStyle(color: textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _NutritionSmallTile extends StatelessWidget {
  final String value;
  final String label;

  const _NutritionSmallTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: textSecondary, fontSize: 11)),
      ],
    );
  }
}
