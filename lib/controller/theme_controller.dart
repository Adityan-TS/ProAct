import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';

class ThemeController extends GetxController {
  RxBool isDarkMode = false.obs;

  final _box = Hive.box('ProAct');

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      bool savedTheme = _box.get('isDarkMode', defaultValue: false);
      isDarkMode.value = savedTheme;
      Get.changeThemeMode(savedTheme ? ThemeMode.dark : ThemeMode.light);
    });
  }


  void toggleTheme(bool value) {
    isDarkMode.value = value;
    _box.put('isDarkMode', value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }
}
