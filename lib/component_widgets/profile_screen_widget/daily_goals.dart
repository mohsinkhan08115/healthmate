import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthmate/controller/bottom_navi_controller/dashboard_controller.dart';

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

  @override
  Widget build(BuildContext context) {
    final DashboardController goalsController = Get.find<DashboardController>();
    return Card(
      elevation: 10,
      child: Column(
        children: [
          Row(children: [Icon(Icons.task), Text("Daily Goals")]),
          SizedBox(height: 20),
          Obx(
            () => GetDailyGoals(
              'Steps Goals',
              steps,
              goalsController.stepsGoal.value,
            ),
          ),

          Obx(
            () => GetDailyGoals(
              "Calories Goals",
              calouies,
              goalsController.caloriesGoal.value,
            ),
          ),

          Obx(
            () => GetDailyGoals(
              "Protein Goals",
              protein,
              goalsController.proteinGoal.value,
            ),
          ),

          Obx(
            () => GetDailyGoals(
              "Water Goals",
              water,
              goalsController.waterGoal.value,
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final stepController = TextEditingController();
                final caloriesController = TextEditingController();
                final proteinController = TextEditingController();
                final waterController = TextEditingController();

                Get.defaultDialog(
                  title: "Edit Daily Goals",
                  radius: 12,
                  content: Column(
                    children: [
                      TextField(
                        controller: stepController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Update Steps Goal",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      SizedBox(height: 15),

                      TextField(
                        controller: caloriesController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Update Calories Goal",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      SizedBox(height: 15),

                      TextField(
                        controller: proteinController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Update Protein Goal",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      SizedBox(height: 15),

                      TextField(
                        controller: waterController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Update Water Goal",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            double updatedSteps =
                                double.tryParse(stepController.text) ?? 10000;

                            double updatedCalories =
                                double.tryParse(caloriesController.text) ??
                                2000;

                            double updatedProtein =
                                double.tryParse(proteinController.text) ?? 75;

                            double updatedWater =
                                double.tryParse(waterController.text) ?? 2000;

                            goalsController.updateGoals(
                              steps: updatedSteps,
                              calories: updatedCalories,
                              protein: updatedProtein,
                              water: updatedWater,
                            );

                            Get.back();
                          },
                          child: Text("Update"),
                        ),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
              ),
              child: Text("Edit Goals", style: TextStyle(color: Colors.white)),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget GetDailyGoals(String text, double value, double goal) {
    double progress = (value / goal).clamp(0.0, 1.0);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text),
            // CHANGED: format to 2 decimal places instead of raw double
            // (e.g. "3.90" instead of "3.90000000004")
            Text(value.toStringAsFixed(2)),
          ],
        ),
        LinearProgressIndicator(
          backgroundColor: Colors.blueGrey,
          color: Colors.green,
          minHeight: 10,
          borderRadius: BorderRadius.circular(8),
          value: progress,
        ),
      ],
    );
  }
}
