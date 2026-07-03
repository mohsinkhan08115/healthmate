import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:healthmate/component_widgets/button_widgets.dart';
import 'package:healthmate/screens/auth_screens/login_screen.dart';
import 'package:healthmate/screens/auth_screens/signup_screen.dart';

class MainAuthScreen extends StatefulWidget {
  const MainAuthScreen({super.key});

  @override
  State<MainAuthScreen> createState() => _MainAuthScreenState();
}

class _MainAuthScreenState extends State<MainAuthScreen> {
  //AppColors appColor = AppColors();
  //late Custombutton custombutton;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,

          decoration: BoxDecoration(color: Colors.white),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              SizedBox(height: 200),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 40),
              Text(
                "Are You Ready For Fit YourSelf !",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Divider(
                color: Colors.black,
                thickness: 1,
                indent: 30,
                endIndent: 30,
              ),
              // SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  "Tracking your daily steps helps you stay active and monitor your physical activity. Walking regularly improves heart health, burns calories, and boosts mood. Aim for a daily step goal to build a consistent and healthy routine.",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.only(left: 40.0, right: 4.0),
                child: Row(
                  spacing: 15,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Custombutton(
                        text: "Sign In",
                        onPressed: () {
                          Get.to(() => AuthScreen());
                        },
                      ),
                    ),
                    Expanded(
                      child: Custombutton(
                        text: "Register",
                        onPressed: () {
                          Get.to(() => RegisterScreen());
                        },
                      ),
                    ),
                    SizedBox(height: 200),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
