import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthmate/component_widgets/dashboard_card_widgets.dart';
import 'package:healthmate/controller/bottom_navi_controller/dashboard_controller.dart';
import 'package:healthmate/core/theme/app_colors.dart';
import 'package:healthmate/screens/bottom_navigation/add_food_manually.dart';
import 'package:healthmate/screens/bottom_navigation/monthly_history.dart';

// ignore: must_be_immutable
class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final DashboardController controller = Get.find();

  void showAddWaterSheet(BuildContext context) async {
    final water = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => WaterIntake(),
    );
    if (water != null) {
      controller.addWater(water);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Today's Progress Header with Run Km chip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Today's Progress",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.stepsTrack,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Run: ${controller.estimatedRunKm.toStringAsFixed(1)} km",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.steps,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 2x2 grid of metric cards
              GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
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
                      goalText: "${controller.stepsGoal.value} steps",
                    ),
                  ),
                  Obx(
                    () => CardWidgets(
                      text: "Calories",
                      value:
                          "${controller.totalCalories.value.toStringAsFixed(1)} kcal",
                      icon: Icons.local_fire_department_rounded,
                      progressValue:
                          (controller.totalCalories.value /
                                  controller.caloriesGoal.value)
                              .clamp(0.0, 1.0),
                      goalText: "${controller.caloriesGoal.value} kcal",
                    ),
                  ),
                  Obx(
                    () => CardWidgets(
                      text: "Water Intake",
                      value:
                          "${controller.totalWater.value.toStringAsFixed(1)} ml",
                      icon: Icons.water_drop_rounded,
                      progressValue:
                          (controller.totalWater.value /
                                  controller.waterGoal.value)
                              .clamp(0.0, 1.0),
                      goalText: "${controller.waterGoal.value} ml",
                    ),
                  ),
                  Obx(
                    () => CardWidgets(
                      text: "Protein",
                      value:
                          "${controller.totalProtein.value.toStringAsFixed(1)} g",
                      icon: Icons.fitness_center_rounded,
                      progressValue:
                          (controller.totalProtein.value /
                                  controller.proteinGoal.value)
                              .clamp(0.0, 1.0),
                      goalText: "${controller.proteinGoal.value} g",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Monthly History Card Button
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MonthlyHistory(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Monthly History",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.textSecondary,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Weekly Summary Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
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
                      "Weekly Summary",
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
                          child: Row(
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.stepsTrack,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.directions_walk_rounded,
                                  color: AppColors.steps,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Obx(
                                      () => Text(
                                        controller.weeklyAverage.toStringAsFixed(
                                          0,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    const Text(
                                      "Avg Steps",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: AppColors.border,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.caloriesTrack,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.local_fire_department_rounded,
                                  color: AppColors.calories,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Obx(
                                      () => Text(
                                        "${controller.weeklyCaloriesAverage.toStringAsFixed(0)} kcal",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    const Text(
                                      "Avg Calories",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Recent Meals Header
              const Text(
                "Recent Meals",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),

              // Recent Meals dynamic list with Empty State
              Obx(() {
                final recentFoods = controller.foods.reversed.take(10).toList();

                if (recentFoods.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 32,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.restaurant_outlined,
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
                          "Track your meals in the Food tab",
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        leading: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: AppColors.caloriesTrack,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.restaurant_rounded,
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
                        subtitle: Text(
                          "${food.calories.toStringAsFixed(0)} kcal",
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
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
