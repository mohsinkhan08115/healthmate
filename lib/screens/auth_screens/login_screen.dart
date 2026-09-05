import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthmate/component_widgets/button_widgets.dart';
import 'package:healthmate/component_widgets/google_button.dart';
import 'package:healthmate/controller/auth_controller/login_controller.dart';
import 'package:healthmate/core/theme/app_colors.dart';
import 'package:healthmate/screens/auth_screens/forget_password.dart';
import 'package:healthmate/screens/auth_screens/signup_screen.dart';

class AuthScreen extends StatelessWidget {
  AuthScreen({super.key});

  final LoginController lgcontroller = LoginController();

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
          decoration: BoxDecoration(color: backgroundColor),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 160),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: TextField(
                  controller: lgcontroller.emailcontroller,
                  style: TextStyle(color: textPrimary, fontSize: 14),
                  decoration: buildInputDecoration("Email"),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: TextField(
                  controller: lgcontroller.passwordcontroller,
                  obscureText: true,
                  style: TextStyle(color: textPrimary, fontSize: 14),
                  decoration: buildInputDecoration("Password"),
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.to(() => const ForgetPassword());
                },
                child: const Text(
                  "Forget Password",
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Custombutton(
                  text: "Sign In",
                  onPressed: () => lgcontroller.buttonlogin(),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Divider(
                      color: borderColor,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      "OR",
                      style: TextStyle(color: textSecondary, fontSize: 13),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: borderColor,
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sign In With Google",
                    style:
                        TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 20),
                  GoogleButton(
                    image: Image.asset("assets/images/Google.png"),
                    onPressed: () => lgcontroller.login(),
                  ),
                ],
              ),
              const SizedBox(height: 80),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(color: textSecondary),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.to(() => RegisterScreen());
                    },
                    child: const Text(
                      "Register",
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
