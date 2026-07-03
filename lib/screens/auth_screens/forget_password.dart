import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  TextEditingController emailcontroller = TextEditingController();
  Future<void> reset() async {
    if (emailcontroller.text.trim().isEmpty) {
      Get.snackbar('Error', "Email is Required");
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailcontroller.text,
      );
      Get.snackbar("Error", "Password reset email sent");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
    // if (!mounted) return;
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => AuthScreen()),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextField(
            controller: emailcontroller,
            decoration: InputDecoration(
              hintText: "Email",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          ElevatedButton(onPressed: (() => reset()), child: Text("Send Link")),
        ],
      ),
    );
  }
}
