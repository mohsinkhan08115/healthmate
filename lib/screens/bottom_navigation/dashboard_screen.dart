import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthmate/component_widgets/dashboard_card_widgets.dart';
import 'package:healthmate/controller/bottom_navi_controller/dashboard_controller.dart';
import 'package:healthmate/core/theme/app_colors.dart';
import 'package:healthmate/models/food_model.dart';
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

  List<foodModel> dummydata = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => Center(
                child: Text(
                  "Run: ${controller.estimatedRunKm.toStringAsFixed(1)} km",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            // SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Today's Progress",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            GridView(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
              ),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                Obx(
                  () => CardWidgets(
                    text: "Steps",
                    value: controller.steps.value.toString(),
                    icon: Icons.directions_walk,
                    progressValue:
                        (controller.steps.value / controller.stepsGoal.value)
                            .clamp(0.0, 1.0),
                    goalText: "${controller.stepsGoal.value} Steps",
                  ),
                ),
                Obx(
                  () => CardWidgets(
                    text: "Calories",
                    value:
                        "${controller.totalCalories.value.toStringAsFixed(1)} kcal",
                    icon: Icons.local_fire_department,
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
                    icon: Icons.water_drop,
                    progressValue:
                        (controller.totalWater.value /
                                controller.waterGoal.value)
                            .clamp(0.0, 1.0),
                    goalText: "${controller.waterGoal.value} ml",
                  ),
                ),
                Obx(
                  () => CardWidgets(
                    text: "Protien",
                    value:
                        "${controller.totalProtein.value.toStringAsFixed(1)} Protein",
                    icon: Icons.apple_outlined,
                    progressValue:
                        (controller.totalProtein.value /
                                controller.proteinGoal.value)
                            .clamp(0.0, 1.0),
                    goalText: "${controller.proteinGoal.value} g",
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MonthlyHistory(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Monthly History",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Recent Meals",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 200,
              child: Obx(() {
                // New: show only the most recent 10 meals, latest first
                final recentFoods = controller.foods.reversed.take(10).toList();

                return ListView.builder(
                  itemCount: recentFoods.length,
                  itemBuilder: (context, index) {
                    final food = recentFoods[index];

                    // New: map back to the real index in controller.foods,
                    // since deleteFood needs the original list's index
                    final originalIndex = controller.foods.length - 1 - index;

                    return Card(
                      elevation: 5,
                      child: ListTile(
                        leading: Icon(Icons.ac_unit),
                        title: Text(food.name),
                        subtitle: Text("${food.calories} kcal"),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            controller.deleteFood(originalIndex);
                          },
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            SizedBox(
              height: 120,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.weeklySummaryBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Card(
                    color: Colors.transparent,
                    elevation: 5,
                    child: Column(
                      children: [
                        Text(
                          "Weekly Summary",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Obx(
                              () => Text(
                                "Avg Steps \n ${controller.weeklyAverage.toStringAsFixed(2)}",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            Obx(
                              () => Text(
                                "Avg Calories \n ${controller.weeklyCaloriesAverage.toStringAsFixed(2)}",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            // Obx(
                            //   () => Text(
                            //     "Active Days \n 2/7",
                            //     style: TextStyle(color: Colors.white),
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
