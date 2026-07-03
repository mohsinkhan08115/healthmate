import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthmate/controller/bottom_navi_controller/dashboard_controller.dart';
import 'package:healthmate/models/food_model.dart';

// ignore: must_be_immutable
class AddFoodMenually extends StatelessWidget {
  AddFoodMenually({super.key});

  TextEditingController foodController = TextEditingController();
  TextEditingController calController = TextEditingController();
  TextEditingController proController = TextEditingController();
  TextEditingController carbController = TextEditingController();
  TextEditingController fatController = TextEditingController();
  TextEditingController fibeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              "Add Food Manually",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: foodController,
              decoration: InputDecoration(
                labelText: "Enter Food",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 5),
            TextField(
              controller: calController,
              decoration: InputDecoration(
                labelText: "Enter Calories",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 5),
            TextField(
              controller: proController,
              decoration: InputDecoration(
                labelText: "Enter Protein",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 5),
            TextField(
              controller: carbController,
              decoration: InputDecoration(
                labelText: "Enter Carbs",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 5),
            TextField(
              controller: fatController,
              decoration: InputDecoration(
                labelText: "Enter Fat",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 5),
            TextField(
              controller: fibeController,
              decoration: InputDecoration(
                labelText: "Enter Fiber",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 5),
            ElevatedButton(
              onPressed: () {
                final newFood = foodModel(
                  uid: uid,
                  name: foodController.text,
                  calories: double.tryParse(calController.text) ?? 0,
                  protein: double.tryParse(proController.text) ?? 0,
                  carbs: double.tryParse(carbController.text) ?? 0,
                  fat: double.tryParse(fatController.text) ?? 0,
                  Fiber: double.tryParse(fibeController.text) ?? 0,
                  date: DateTime.now(),
                );

                Get.find<DashboardController>().addFood(newFood);

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}

// Water Intake---------------------------------------
// ignore: must_be_immutable
class WaterIntake extends StatelessWidget {
  WaterIntake({super.key});
  TextEditingController WaterController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        height: 500,
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              "Add Water",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: WaterController,
              decoration: InputDecoration(
                labelText: "Enter water (ml)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                double water = double.tryParse(WaterController.text) ?? 0;
                Navigator.pop(context, water);
              },
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
