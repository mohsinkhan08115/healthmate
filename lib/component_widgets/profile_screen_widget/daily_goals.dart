import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthmate/controller/bottom_navi_controller/dashboard_controller.dart';
import 'package:healthmate/core/theme/app_colors.dart';

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

  InputDecoration _buildDialogInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DashboardController goalsController = Get.find<DashboardController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
            Row(
              children: const [
                Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  "Daily Goals",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(
              () => _buildGoalRow(
                'Steps Goal',
                steps,
                goalsController.stepsGoal.value,
                AppColors.steps,
                AppColors.stepsTrack,
                "steps",
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => _buildGoalRow(
                "Calories Goal",
                calouies,
                goalsController.caloriesGoal.value,
                AppColors.calories,
                AppColors.caloriesTrack,
                "kcal",
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => _buildGoalRow(
                "Protein Goal",
                protein,
                goalsController.proteinGoal.value,
                AppColors.protein,
                AppColors.proteinTrack,
                "g",
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => _buildGoalRow(
                "Water Goal",
                water,
                goalsController.waterGoal.value,
                AppColors.water,
                AppColors.waterTrack,
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
                    titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    backgroundColor: Colors.white,
                    radius: 16,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    content: Column(
                      children: [
                        TextField(
                          controller: stepController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 14),
                          decoration: _buildDialogInputDecoration("Steps Goal"),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: caloriesController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 14),
                          decoration: _buildDialogInputDecoration("Calories Goal (kcal)"),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: proteinController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 14),
                          decoration: _buildDialogInputDecoration("Protein Goal (g)"),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: waterController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 14),
                          decoration: _buildDialogInputDecoration("Water Goal (ml)"),
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

  Widget _buildGoalRow(String text, double value, double goal, Color fillColor, Color trackColor, String unit) {
    double progress = (value / goal).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              "${value.toStringAsFixed(0)} / ${goal.toStringAsFixed(0)} $unit",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            backgroundColor: trackColor,
            valueColor: AlwaysStoppedAnimation<Color>(fillColor),
            minHeight: 4,
            value: progress,
          ),
        ),
      ],
    );
  }
}
