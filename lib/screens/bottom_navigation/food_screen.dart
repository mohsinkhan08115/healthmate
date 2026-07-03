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

  // ── Goals (adjust to your real values) ──────────────────
  static const double _calGoal = 2000;
  static const double _proteinGoal = 150;

  void showAddOptionsSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "What do you want to add?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: Icon(Icons.fastfood, color: AppColors.calories),
                title: const Text("Add Food"),
                onTap: () {
                  Navigator.pop(context);
                  showAddFoodBottomSheet();
                },
              ),
              ListTile(
                leading: Icon(Icons.water_drop, color: AppColors.water),
                title: const Text("Add Water"),
                onTap: () {
                  Navigator.pop(context);
                  showAddWaterSheet();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showAddWaterSheet() async {
    final water = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => WaterIntake(),
    );
    if (water != null) controller.addWater(water);
  }

  void showAddFoodBottomSheet() async {
    final newFood = await showModalBottomSheet<foodModel>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      builder: (context) => AddFoodMenually(),
    );
    if (newFood != null) controller.addFood(newFood);
  }

  void showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.deepOrangeAccent, Color(0xFFFF3D00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title ──
              const Text(
                "Today's Nutrition",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // ── Top row: Calories | Protein ────────────────
              Row(
                children: [
                  Expanded(
                    child: _NutritionBigTile(
                      label: "Calories",
                      value: totalCal.toStringAsFixed(0),
                      goal: "of ${_calGoal.toInt()} goal",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _NutritionBigTile(
                      label: "Protein",
                      value: "${totalProtein.toStringAsFixed(0)}g",
                      goal: "of ${_proteinGoal.toInt()}g goal",
                    ),
                  ),
                ],
              ),
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
          children: [
            const SizedBox(height: 20),

            // ── Header banner ──────────────────────────────
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: AppColors.foodGradient,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Food Logger",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Track your nutrition & stay healthy",
                        style: TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Log Your Food card ─────────────────────────
            Card(
              elevation: 20,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Add Your Food",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: showAddOptionsSheet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.nutritionCardBg,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.add, color: Colors.white),
                              Text(
                                "Add Manually",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: showImagePickerSheet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.water,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.camera_alt, color: Colors.white),
                              Text(
                                "Scan Food",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            // ✅ TODAY'S NUTRITION CARD (new)
            _buildNutritionCard(),

            // ── Today's Meals ──────────────────────────────
            Column(
              children: [
                QuickAddScreen(),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 230),
                  child: Text(
                    "Today's Meals",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Obx(() {
                  return SizedBox(
                    height: 220,
                    child: ListView.builder(
                      // Changed: use todaysFoods instead of all foods, so only today's meals show
                      itemCount: controller.todaysFoods.length,
                      itemBuilder: (context, index) {
                        final food = controller.todaysFoods[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.surface),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AppColors.primarySurface,
                            ),
                            child: ListTile(
                              leading: Icon(
                                Icons.ac_unit,
                                color: AppColors.nutritionCardBg,
                              ),
                              title: Text(
                                food.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                              subtitle: Wrap(
                                spacing: 6,
                                children: [
                                  Text(
                                    "Cal: ${food.calories}",
                                    style: TextStyle(color: AppColors.calories),
                                  ),
                                  Text(
                                    "P: ${food.protein}",
                                    style: TextStyle(color: AppColors.protein),
                                  ),
                                  Text(
                                    "C: ${food.carbs}",
                                    style: TextStyle(
                                      color: AppColors.primarySoft,
                                    ),
                                  ),
                                  Text(
                                    "F: ${food.fat}",
                                    style: TextStyle(color: AppColors.steps),
                                  ),
                                  Text(
                                    "Fib: ${food.Fiber}",
                                    style: TextStyle(color: AppColors.water),
                                  ),
                                ],
                              ),
                              trailing: Text(
                                DateFormat('hh:mm a').format(food.date),
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  Sub-widgets for the Nutrition Card
// ══════════════════════════════════════════════════════════

/// Large tile: used for Calories & Protein (shows goal)
class _NutritionBigTile extends StatelessWidget {
  final String label;
  final String value;
  final String goal;

  const _NutritionBigTile({
    required this.label,
    required this.value,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            goal,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// Small tile: used for Carbs, Fat, Fiber (no goal)
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
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
