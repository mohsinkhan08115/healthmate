import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:healthmate/controller/bottom_navi_controller/dashboard_controller.dart';
import 'package:healthmate/controller/bottom_navi_controller/profile_controller.dart';
import 'package:healthmate/controller/bottom_navi_controller/step_counter_controller.dart';
import 'package:healthmate/controller/theme_controller.dart';
import 'package:healthmate/core/theme/app_theme.dart';
import 'package:healthmate/firebase_options.dart';
import 'package:healthmate/screens/splish_screen/splish_screen.dart';
import 'package:healthmate/services/notification_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.openBox('profileBox');
  await Hive.openBox('stepsBox');
  await Hive.box('stepsBox').compact();
  await Hive.openBox('foodBox');
  await Hive.openBox('reminderBox');
  await Hive.openBox('historyBox');

  await NotificationService.init();

  Get.put(ThemeController(), permanent: true);
  Get.put(ProfileController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'HealthMate',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode,
        initialBinding: BindingsBuilder(() {
          Get.put(StepsController());
          Get.put(DashboardController());
        }),
        home: const SplishScreen(),
      ),
    );
  }
}
