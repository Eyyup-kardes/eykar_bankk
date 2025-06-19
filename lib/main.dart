import 'package:eykar_bank/views/auth/login/login_page.dart';
import 'package:eykar_bank/views/home/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'utils/pre_main/pre_main.dart';

Future<void> main() async {
  await PreMain.preMain();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.put(SettingsController());
    return Obx(() {
      return GetMaterialApp(
        title: 'Eykar Bank',
        debugShowCheckedModeBanner: false,
        theme: settingsController.isDarkMode.value
            ? ThemeData.dark()
            : ThemeData.light(),
        home: LoginPage(),
      );
    });
  }
}
