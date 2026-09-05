import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthmate/component_widgets/dashboard_card_widgets.dart';
import 'package:healthmate/component_widgets/food_tile_avatar.dart';
import 'package:healthmate/controller/bottom_navi_controller/dashboard_controller.dart';
import 'package:healthmate/core/theme/app_colors.dart';
import 'package:healthmate/core/theme/app_theme.dart';
import 'package:healthmate/screens/bottom_navigation/monthly_history.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final DashboardController controller = Get.find<DashboardController>();

  void showAddWaterSheet(BuildContext context) {
    controller.addWater(250);
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── Today's Progress Header with Run Km chip ────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's Progress",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Run: ${controller.estimatedRunKm.toStringAsFixed(1)} km",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.emerald,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── 2x2 Progress Stat Cards (childAspectRatio: 1.15) ─────────────
              GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.15,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Obx(
                    () => CardWidgets(
                      text: "Steps",
                      value: controller.steps.value.toString(),
                      icon: Icons.directions_walk_rounded,
                      progressValue:
                          (controller.steps.value / controller.stepsGoal.value)
                              .clamp(0.0, 1.0),
                      goalText: "${controller.stepsGoal.value}",
                    ),
                  ),
                  Obx(
                    () => CardWidgets(
                      text: "Calories",
                      value:
                          "${controller.totalCalories.value.toStringAsFixed(0)} kcal",
                      icon: Icons.local_fire_department_rounded,
                      progressValue:
                          (controller.totalCalories.value /
                                  controller.caloriesGoal.value)
                              .clamp(0.0, 1.0),
                      goalText: "${controller.caloriesGoal.value.toInt()} kcal",
                    ),
                  ),
                  Obx(
                    () => CardWidgets(
                      text: "Water Intake",
                      value:
                          "${controller.totalWater.value.toStringAsFixed(0)} ml",
                      icon: Icons.water_drop_rounded,
                      progressValue:
                          (controller.totalWater.value /
                                  controller.waterGoal.value)
                              .clamp(0.0, 1.0),
                      goalText: "${controller.waterGoal.value.toInt()} ml",
                    ),
                  ),
                  Obx(
                    () => CardWidgets(
                      text: "Protein",
                      value:
                          "${controller.totalProtein.value.toStringAsFixed(0)} g",
                      icon: Icons.fitness_center_rounded,
                      progressValue:
                          (controller.totalProtein.value /
                                  controller.proteinGoal.value)
                              .clamp(0.0, 1.0),
                      goalText: "${controller.proteinGoal.value.toInt()} g",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Full-Width Soft-Lavender Pill Action Button ─────────────────
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MonthlyHistory()),
                    );
                  },
                  icon: const Text("📅", style: TextStyle(fontSize: 16)),
                  label: const Text(
                    "View Monthly History",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.lavenderText,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.lavenderPillDark
                        : AppColors.lavenderPillLight,
                    foregroundColor: AppColors.lavenderText,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── WEEKLY SUMMARY CARD (Indigo/Violet Gradient) ────────────────
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.indigoGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5B4DF5).withOpacity(0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Title: Chart icon + "Weekly Summary"
                    Row(
                      children: const [
                        Icon(
                          Icons.insert_chart_outlined_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Weekly Summary",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Dual Frosted-Glass Stat Boxes
                    Row(
                      children: [
                        // Left Stat Box: Avg Steps
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Avg Steps",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Obx(
                                  () => Text(
                                    controller.weeklyAverage.toStringAsFixed(0),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Right Stat Box: Avg Calories
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Avg Calories",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Obx(
                                  () => Text(
                                    "${controller.weeklyCaloriesAverage.toStringAsFixed(0)} kcal",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── RECENT MEALS SECTION ─────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent Meals",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.lavenderPillDark
                            : AppColors.lavenderPillLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${controller.foods.length} items",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lavenderText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Dynamic List with Empty State Card
              Obx(() {
                final recentFoods = controller.foods.reversed.take(10).toList();

                if (recentFoods.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 28,
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
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.restaurant_rounded,
                            size: 28,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "No meals logged yet",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Add food from the Food tab",
                          style: TextStyle(fontSize: 12, color: textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentFoods.length,
                  itemBuilder: (context, index) {
                    final food = recentFoods[index];
                    final originalIndex = controller.foods.length - 1 - index;

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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          "${food.calories.toStringAsFixed(0)} kcal",
                          style: TextStyle(fontSize: 12, color: textSecondary),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.calories,
                            size: 20,
                          ),
                          onPressed: () {
                            controller.deleteFood(originalIndex);
                          },
                        ),
                      ),
                    );
                  },
                );
              }),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
