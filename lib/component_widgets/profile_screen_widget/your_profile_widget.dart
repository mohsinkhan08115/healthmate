// REMOVED: cloud_firestore and firebase_auth imports (no longer needed)
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // ADDED: to access ProfileController
import 'package:healthmate/controller/bottom_navi_controller/profile_controller.dart'; // ADDED

class YourProfileWidget extends StatelessWidget {
  YourProfileWidget({super.key});

  // ADDED: get the already-registered ProfileController (permanent: true in main.dart)
  final ProfileController controller = Get.find<ProfileController>();

  // REMOVED: user field and getUserData() — no longer needed,
  // ProfileController already loads this from Hive on init.

  @override
  Widget build(BuildContext context) {
    // CHANGED: wrap in Obx so it updates reactively if profile changes,
    // instead of FutureBuilder + Firestore.
    return Obx(() {
      return Card(
        color: Colors.blueAccent,
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage("assets/images/profile.jpg"),
                ),
                title: Text(
                  controller.name.value.isEmpty
                      ? "User"
                      : controller.name.value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text("Manage Your Health Goals"),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 20,
                children: [
                  Card(
                    color: Colors.blue,
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [Text("Age: ${controller.age.value}")],
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.blue,
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text("Weight: ${controller.weight.value} kg"),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.blue,
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text("Height: ${controller.height.value} ft"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      );
    });
  }
}
