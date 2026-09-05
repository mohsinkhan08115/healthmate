import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthmate/component_widgets/button_widgets.dart';
import 'package:healthmate/component_widgets/google_button.dart';
import 'package:healthmate/controller/auth_controller/auth_controller.dart';
import 'package:healthmate/core/theme/app_colors.dart';
import 'package:healthmate/screens/auth_screens/info_screen.dart';

// ignore: must_be_immutable
class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final AuthController controller = Get.put(AuthController());

  bool isLoading = false;
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.15)
        : AppColors.lightBorder;

    InputDecoration buildInputDecoration(String hint) {
      return InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: textSecondary, fontSize: 14),
        filled: true,
        fillColor: surfaceColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(color: backgroundColor),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 50),
                Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller.emailcontroller,
                  style: TextStyle(color: textPrimary, fontSize: 14),
                  decoration: buildInputDecoration("Email"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: controller.passwordcontroller,
                  obscureText: true,
                  style: TextStyle(color: textPrimary, fontSize: 14),
                  decoration: buildInputDecoration("Password"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: controller.confirmpasswordcontroller,
                  obscureText: true,
                  style: TextStyle(color: textPrimary, fontSize: 14),
                  decoration: buildInputDecoration("Confirm Password"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  style: TextStyle(color: textPrimary, fontSize: 14),
                  decoration: buildInputDecoration("Full Name"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: textPrimary, fontSize: 14),
                  decoration: buildInputDecoration("Age"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: textPrimary, fontSize: 14),
                  decoration: buildInputDecoration("Weight"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: heightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: textPrimary, fontSize: 14),
                  decoration: buildInputDecoration("Height"),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Obx(() {
                    return controller.isLoading.value
                        ? const CircularProgressIndicator(color: AppColors.primary)
                        : Custombutton(
                            text: "Sign Up",
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InfoScreen(),
                                ),
                              );
                              controller.signup(
                                name: nameController.text,
                                age: ageController.text,
                                weight: weightController.text,
                                height: heightController.text,
                              );
                            },
                          );
                  }),
                ),
                const SizedBox(height: 20),
                GoogleButton(
                  image: Image.asset("assets/images/Google.png"),
                  onPressed: controller.signInWithGoogle,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
