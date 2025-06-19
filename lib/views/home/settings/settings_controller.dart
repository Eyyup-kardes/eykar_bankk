import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController{

  // Örnek bir değişken
  var isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromPrefs(); // Uygulama başladığında tema ayarını oku
  }


  // Tema değişikliğini tetikleyen metod
  void toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    Get.changeTheme(isDarkMode.value ? ThemeData.dark() : ThemeData.light());
    await _saveThemeToPrefs(isDarkMode.value); // Değişikliği kaydet
  }

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    isDarkMode.value = isDark;
    Get.changeTheme(isDark ? ThemeData.dark() : ThemeData.light());
  }

  Future<void> _saveThemeToPrefs(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

}