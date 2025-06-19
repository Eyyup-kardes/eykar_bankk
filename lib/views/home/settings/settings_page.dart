import 'package:eykar_bank/views/home/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';



class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController = Get.put(SettingsController());
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Ayarlar',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Karanlık Mod'),
              Switch(
                value: settingsController.isDarkMode.value,
                onChanged: (value) => settingsController.toggleTheme(),
              ),
            ],
          )),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ayarlar güncellendi')),
              );
            },
            child: const Text('Ayarları Güncelle'),
          ),
        ],
      ),
    );
  }
}
