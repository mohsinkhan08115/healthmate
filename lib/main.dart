import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:healthmate/controller/bottom_navi_controller/dashboard_controller.dart';
import 'package:healthmate/controller/bottom_navi_controller/profile_controller.dart';
import 'package:healthmate/controller/bottom_navi_controller/step_counter_controller.dart';
import 'package:healthmate/firebase_options.dart';
import 'package:healthmate/screens/splish_screen/splish_screen.dart';
import 'package:healthmate/services/notification_service.dart';
import 'package:healthmate/services/step_service_manager.dart'; // ADDED
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // ← reads dotenv.env here
  );
  // Step 1: Open ALL boxes first
  await Hive.openBox('profileBox');
  await Hive.openBox('stepsBox');
  await Hive.openBox('foodBox');
  await Hive.openBox('reminderBox');
  await Hive.openBox('historyBox');

  // Step 2: Init notifications FULLY before any controller touches it
  await NotificationService.init();

  // ADDED: register the foreground-service config (does NOT start it yet —
  // actual start happens later, e.g. inside StepsController.onInit()).
  await StepServiceManager.initForegroundTask();

  // Step 3: Register ProfileController AFTER both boxes and notifications
  // are ready. permanent:true ensures GetX never destroys this controller
  // even when navigating away — so switch states stay in memory too.
  Get.put(ProfileController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HealthMate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialBinding: BindingsBuilder(() {
        Get.put(StepsController());
        // Get.put(FoodController());
        Get.put(DashboardController());
        // ProfileController already registered in main() above — do NOT re-add
      }),
      home: const SplishScreen(),
    );
  }
}
