import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthmate/component_widgets/button_widgets.dart';
import 'package:healthmate/controller/auth_controller/auth_controller.dart';

// ignore: must_be_immutable
class InfoScreen extends StatelessWidget {
  InfoScreen({super.key});

  final AuthController controller = Get.put(AuthController());

  bool isLoading = false;
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.white),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              spacing: 10,
              children: [
                SizedBox(height: 50),
                Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),

                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "Full Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Age",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                TextField(
                  controller: weightController,
                  decoration: InputDecoration(
                    hintText: "Weight",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                TextField(
                  controller: heightController,
                  decoration: InputDecoration(
                    hintText: "Height",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.only(left: 30.0, right: 30),
                  child: Obx(() {
                    return controller.isLoading.value
                        ? CircularProgressIndicator()
                        : Custombutton(
                            text: "Sign Up",
                            onPressed: () {
                              controller.completeGoogleProfile(
                                name: nameController.text,
                                age: ageController.text,
                                weight: weightController.text,
                                height: heightController.text,
                              );
                            },
                          );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
