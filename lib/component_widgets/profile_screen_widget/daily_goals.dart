import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthmate/controller/bottom_navi_controller/dashboard_controller.dart';
import 'package:healthmate/core/theme/app_colors.dart';
import 'package:healthmate/core/theme/app_theme.dart';

class DailyGoals extends StatelessWidget {
  final double steps;
  final double calouies;
  final double protein;
  final double water;
  const DailyGoals({
    super.key,
    required this.steps,
    required this.calouies,
    required this.protein,
    required this.water,
  });

  InputDecoration _buildDialogInputDecoration(BuildContext context, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white.withOpacity(0.15) : AppColors.lightBorder;
    final labelColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: labelColor, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? Colors.white.withOpacity(0.06) : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final DashboardController goalsController = Get.find<DashboardController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
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
            Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Daily Goals",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(
              () => _buildGoalRow(
                context,
                'Steps Goal',
                steps,
                goalsController.stepsGoal.value,
                AppColors.steps,
                AppColors.steps.withOpacity(isDark ? 0.2 : 0.12),
                "steps",
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => _buildGoalRow(
                context,
                "Calories Goal",
                calouies,
                goalsController.caloriesGoal.value,
                AppColors.calories,
                AppColors.calories.withOpacity(isDark ? 0.2 : 0.12),
                "kcal",
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => _buildGoalRow(
                context,
                "Protein Goal",
                protein,
                goalsController.proteinGoal.value,
                AppColors.protein,
                AppColors.protein.withOpacity(isDark ? 0.2 : 0.12),
                "g",
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => _buildGoalRow(
                context,
                "Water Goal",
                water,
                goalsController.waterGoal.value,
                AppColors.water,
                AppColors.water.withOpacity(isDark ? 0.2 : 0.12),
                "ml",
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  final stepController = TextEditingController(text: goalsController.stepsGoal.value.toStringAsFixed(0));
                  final caloriesController = TextEditingController(text: goalsController.caloriesGoal.value.toStringAsFixed(0));
                  final proteinController = TextEditingController(text: goalsController.proteinGoal.value.toStringAsFixed(0));
                  final waterController = TextEditingController(text: goalsController.waterGoal.value.toStringAsFixed(0));

                  Get.defaultDialog(
                    title: "Edit Daily Goals",
                    titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary),
                    backgroundColor: surfaceColor,
                    radius: 16,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    content: Column(
                      children: [
                        TextField(
                          controller: stepController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 14, color: textPrimary),
                          decoration: _buildDialogInputDecoration(context, "Steps Goal"),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: caloriesController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 14, color: textPrimary),
                          decoration: _buildDialogInputDecoration(context, "Calories Goal (kcal)"),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: proteinController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 14, color: textPrimary),
                          decoration: _buildDialogInputDecoration(context, "Protein Goal (g)"),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: waterController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 14, color: textPrimary),
                          decoration: _buildDialogInputDecoration(context, "Water Goal (ml)"),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () {
                              double updatedSteps = double.tryParse(stepController.text) ?? 10000;
                              double updatedCalories = double.tryParse(caloriesController.text) ?? 2000;
                              double updatedProtein = double.tryParse(proteinController.text) ?? 75;
                              double updatedWater = double.tryParse(waterController.text) ?? 2000;

                              goalsController.updateGoals(
                                steps: updatedSteps,
                                calories: updatedCalories,
                                protein: updatedProtein,
                                water: updatedWater,
                              );
                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Save Goals", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Edit Goals", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalRow(BuildContext context, String text, double value, double goal, Color fillColor, Color trackColor, String unit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    double progress = (value / goal).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
            Text(
              "${value.toStringAsFixed(0)} / ${goal.toStringAsFixed(0)} $unit",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            backgroundColor: trackColor,
            valueColor: AlwaysStoppedAnimation<Color>(fillColor),
            minHeight: 6,
            value: progress,
          ),
        ),
      ],
    );
  }
}
