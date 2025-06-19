import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_or_home_controller.dart';
import 'email_verification_page.dart';
import 'face_auth_page.dart';
import 'login_page.dart';

class LoginOrHome extends StatelessWidget {
  const LoginOrHome({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginOrHomeController());

    return Obx(() {
      if (controller.isLoggedIn.value) {
        if (!controller.isEmailVerified.value) {
          return const EmailVerificationPendingPage();
        } else if (controller.currentUser.value != null) {
          // 🔥 Yüz doğrulama için gerekli model burada!
          return FaceAuthPage(userModel: controller.currentUser.value!);
        } else {
          return SafeArea(
            child: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 20,
                      children: [
                        Text("Kullanıcı bilgileri yükleniyor..."),
                        CircularProgressIndicator(),
                      ],
                    ),

                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Get.offAll(() => LoginPage());
                      },
                      child: Text('Yeniden Giriş Yap'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      } else {
        return LoginPage();
      }
    });
  }
}
