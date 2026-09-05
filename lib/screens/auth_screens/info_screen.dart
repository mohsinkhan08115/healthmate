import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthmate/component_widgets/button_widgets.dart';
import 'package:healthmate/controller/auth_controller/auth_controller.dart';
import 'package:healthmate/core/theme/app_colors.dart';

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
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          decoration: BoxDecoration(color: backgroundColor),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 50),
                Text(
                  "Complete Profile",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
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
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: textPrimary, fontSize: 14),
                  decoration: buildInputDecoration("Weight"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: heightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: textPrimary, fontSize: 14),
                  decoration: buildInputDecoration("Height"),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Obx(() {
                    return controller.isLoading.value
                        ? const CircularProgressIndicator(color: AppColors.primary)
                        : Custombutton(
                            text: "Submit",
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
