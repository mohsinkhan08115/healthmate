import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  final Box _box = Hive.box('profileBox');
  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    final savedTheme = _box.get('isDarkMode', defaultValue: false);
    isDarkMode.value = savedTheme is bool ? savedTheme : false;
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _box.put('isDarkMode', isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  ThemeMode get themeMode => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
}
