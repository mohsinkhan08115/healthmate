import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthmate/controller/bottom_navi_controller/add_food_image.dart';
import 'package:healthmate/controller/bottom_navi_controller/dashboard_controller.dart';
import 'package:healthmate/core/theme/app_colors.dart';
import 'package:healthmate/models/food_model.dart';
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

  // ── Goals ────────────────────────────────────────────────
  static const double _calGoal = 2000;
  static const double _proteinGoal = 150;

  void showAddOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Choose Option",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: AppColors.caloriesTrack,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.restaurant_rounded, color: AppColors.calories, size: 20),
                  ),
                  title: const Text(
                    "Add Food",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    showAddFoodBottomSheet();
                  },
                ),
                ListTile(
                  leading: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: AppColors.waterTrack,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.water_drop_rounded, color: AppColors.water, size: 20),
                  ),
                  title: const Text(
                    "Add Water",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    showAddWaterSheet();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showAddWaterSheet() async {
    final water = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => WaterIntake(),
    );
    if (water != null) controller.addWater(water);
  }

  void showAddFoodBottomSheet() async {
    final newFood = await showModalBottomSheet<foodModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddFoodMenually(),
    );
    if (newFood != null) controller.addFood(newFood);
  }

  void showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddFoodImage(),
    );
  }

  // ── Today's Nutrition Card ───────────────────────────────
  Widget _buildNutritionCard() {
    return Obx(() {
      // Compute totals from the food list
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
              // ── Title ──
              const Text(
                "Today's Nutrition",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // ── Top row: Calories | Protein ────────────────
              Row(
                children: [
                  Expanded(
                    child: _NutritionBigTile(
                      label: "Calories",
                      value: totalCal.toStringAsFixed(0),
                      goal: "of ${_calGoal.toInt()} kcal",
                      color: AppColors.calories,
                      trackColor: AppColors.caloriesTrack,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NutritionBigTile(
                      label: "Protein",
                      value: "${totalProtein.toStringAsFixed(0)}g",
                      goal: "of ${_proteinGoal.toInt()}g",
                      color: AppColors.protein,
                      trackColor: AppColors.proteinTrack,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 16),

              // ── Bottom row: Carbs | Fat | Fiber ───────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NutritionSmallTile(
                    value: "${totalCarbs.toStringAsFixed(0)}g",
                    label: "Carbs",
                  ),
                  _NutritionSmallTile(
                    value: "${totalFat.toStringAsFixed(0)}g",
                    label: "Fat",
                  ),
                  _NutritionSmallTile(
                    value: "${totalFiber.toStringAsFixed(0)}g",
                    label: "Fiber",
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
                    "Food Logger",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Track your nutrition and stay healthy",
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Add Food",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
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
                            icon: const Icon(Icons.camera_alt_rounded, size: 18),
                            label: const Text(
                              "Scan Food",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary, width: 1.5),
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
            _buildNutritionCard(),

            // Quick Add widget
            QuickAddScreen(),

            // Today's Meals Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: const [
                  Text(
                    "Today's Meals",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.restaurant_menu_rounded,
                          size: 36,
                          color: AppColors.textSecondary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "No meals logged yet",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Start adding your meals to track your nutrition.",
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        leading: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: AppColors.caloriesTrack,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.local_dining_rounded,
                            color: AppColors.calories,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          food.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
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
                                style: const TextStyle(color: AppColors.protein, fontSize: 11),
                              ),
                              Text(
                                "C: ${food.carbs.toStringAsFixed(0)}g",
                                style: const TextStyle(color: AppColors.water, fontSize: 11),
                              ),
                              Text(
                                "F: ${food.fat.toStringAsFixed(0)}g",
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateFormat('hh:mm a').format(food.date),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.calories, size: 20),
                              onPressed: () {
                                final originalIndex = controller.foods.indexOf(food);
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

// ══════════════════════════════════════════════════════════
//  Sub-widgets for the Nutrition Card
// ══════════════════════════════════════════════════════════

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
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            goal,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
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
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }
}

