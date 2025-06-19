import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/homepage_controller.dart';
import 'auth/login/login_page.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomepageController());

    return StreamBuilder(
      stream: controller.currentUserStream,
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Eykar Bank')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!asyncSnapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Eykar Bank')),
            body: Center(child: Column(
              children: [
                Text('Kullanıcı verisi bulunamadı'),
                ElevatedButton(
                  onPressed: () async {
                    await controller.auth.signOut();
                    Get.offAll(() => LoginPage());
                  },
                  child: const Text('Çıkış Yap'),
                ),
              ],
            )),
          );
        }

        return Scaffold(
          bottomNavigationBar: Obx(() {
            return BottomNavigationBar(
              backgroundColor: Colors.blue,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.black,
              type: BottomNavigationBarType.fixed,
              showUnselectedLabels: true,
              currentIndex: controller.currentIndex.value,
              onTap: controller.changeTab,
              items: const [
                BottomNavigationBarItem(
                  label: 'Hesap',
                  icon: Icon(Icons.account_balance),
                ),
                BottomNavigationBarItem(
                  label: 'Transfer',
                  icon: Icon(Icons.transfer_within_a_station),
                ),
                BottomNavigationBarItem(
                  label: 'Ayarlar',
                  icon: Icon(Icons.settings),
                ),
                BottomNavigationBarItem(
                  label: 'Profil',
                  icon: Icon(Icons.person),
                ),
              ],
            );
          }),
          body: Obx(() {
            return controller.pages[controller.currentIndex.value];
          }),
        );
      },
    );
  }
}
