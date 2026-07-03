import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthmate/component_widgets/button_widgets.dart';
import 'package:healthmate/component_widgets/google_button.dart';
import 'package:healthmate/controller/auth_controller/login_controller.dart';
import 'package:healthmate/screens/auth_screens/forget_password.dart';
import 'package:healthmate/screens/auth_screens/signup_screen.dart';

class AuthScreen extends StatelessWidget {
  AuthScreen({super.key});

  final LoginController lgcontroller = LoginController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          // width: double.infinity,
          decoration: BoxDecoration(color: Colors.white),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 160),
              // SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: lgcontroller.emailcontroller,
                  decoration: InputDecoration(
                    hintText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: lgcontroller.passwordcontroller,
                  decoration: InputDecoration(
                    hintText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.to(ForgetPassword());
                },
                child: Text("Forget Password"),
              ),
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30),
                child: Custombutton(
                  text: ("Sign In"),
                  onPressed: (() => lgcontroller.buttonlogin()),
                ),
              ),
              SizedBox(height: 40),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Divider(
                      color: const Color.fromARGB(255, 5, 4, 4),
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("OR"),
                  ),
                  Expanded(
                    child: Divider(
                      color: const Color.fromARGB(255, 16, 7, 7),
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: .center,
                children: [
                  Text("Sign In WIth Google"),
                  SizedBox(width: 30),
                  GoogleButton(
                    image: Image.asset("assets/images/Google.png"),
                    onPressed: (() => lgcontroller.login()),
                  ),
                ],
              ),
              SizedBox(height: 100),
              Row(
                mainAxisAlignment: .center,
                children: [
                  SizedBox(width: 20),
                  Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Get.to(RegisterScreen());
                    },
                    child: Text("Register"),
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
