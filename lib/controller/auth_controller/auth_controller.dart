import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthmate/controller/bottom_navi_controller/profile_controller.dart';
import 'package:hive/hive.dart';
import 'package:healthmate/screens/Home_Screen/home_screen.dart';
import 'package:healthmate/screens/auth_screens/info_screen.dart';
import 'package:healthmate/screens/auth_screens/wrapper.dart';
import 'package:healthmate/services/auth_services.dart';

class AuthController extends GetxController {
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController confirmpasswordcontroller = TextEditingController();

  final AuthService _authService = AuthService();
  RxBool isLoading = false.obs;

  Box get _profileBox => Hive.box('profileBox');

  Future<void> signup({
    required String name,
    required String age,
    required String weight,
    required String height,
  }) async {
    try {
      if (passwordcontroller.text.trim() !=
          confirmpasswordcontroller.text.trim()) {
        Get.snackbar("Error", "Passwords do not match");
        return;
      }

      isLoading.value = true;

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailcontroller.text.trim(),
            password: passwordcontroller.text.trim(),
          );

      String uid = userCredential.user!.uid;

      await saveUserData(
        uid: uid,
        email: emailcontroller.text.trim(),
        name: name,
        age: age,
        weight: weight,
        height: height,
      );

      print("DATA SAVED");

      Get.snackbar("Success", "Account Created");

      Get.offAll(() => Wrapper());
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? "Signup Failed");
    } catch (e) {
      print(e);
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailcontroller.dispose();
    passwordcontroller.dispose();
    confirmpasswordcontroller.dispose();
    super.onClose();
  }

  Future<void> signInWithGoogle() async {
    UserCredential? userCredential = await _authService.signInWithGoogle();

    if (userCredential == null) return;

    final uid = userCredential.user!.uid;

    final savedUid = _profileBox.get('uid');
    final exists = savedUid == uid;

    // first time user
    if (!exists) {
      Get.off(() => InfoScreen());
    }
    // old user
    else {
      Get.offAll(() => HomeScreen());
    }
  }

  Future<void> completeGoogleProfile({
    required String name,
    required String age,
    required String weight,
    required String height,
  }) async {
    try {
      isLoading.value = true;

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      await saveUserData(
        uid: user.uid,
        email: user.email ?? "",
        name: name,
        age: age,
        weight: weight,
        height: height,
      );

      Get.offAll(() => Wrapper());
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> emailSignup({
    required String name,
    required String age,
    required String weight,
    required String height,
  }) async {
    try {
      isLoading.value = true;

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailcontroller.text.trim(),
            password: passwordcontroller.text.trim(),
          );

      final uid = userCredential.user!.uid;

      await saveUserData(
        uid: uid,
        email: emailcontroller.text.trim(),
        name: name,
        age: age,
        weight: weight,
        height: height,
      );

      Get.offAll(() => Wrapper());
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveUserData({
    required String uid,
    required String email,
    required String name,
    required String age,
    required String weight,
    required String height,
  }) async {
    await _profileBox.put('uid', uid);
    await _profileBox.put('email', email);
    await _profileBox.put('name', name);
    await _profileBox.put('age', int.tryParse(age) ?? 0);
    await _profileBox.put('weight', double.tryParse(weight) ?? 0.0);
    await _profileBox.put('height', double.tryParse(height) ?? 0.0);
    await _profileBox.put('createdAt', DateTime.now().toIso8601String());

    // ADDED: refresh ProfileController's in-memory values now that
    // Hive has the new data — onInit() already ran before signup.
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().loadProfile();
    }
  }
}
