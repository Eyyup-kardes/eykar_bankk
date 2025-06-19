import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eykar_bank/views/auth/login/face_auth_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/my_auth_model.dart';

class EmailVerificationPendingPage extends StatelessWidget {
  const EmailVerificationPendingPage({super.key});

  Future<void> _resendVerificationEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload(); // durumu güncelle
    user = FirebaseAuth.instance.currentUser;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      Get.snackbar(
        "Email Gönderildi",
        "Doğrulama bağlantısı email adresinize tekrar gönderildi.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } else if (user != null && user.emailVerified) {
      Get.snackbar(
        "Zaten Doğrulandı",
        "Email adresiniz zaten doğrulanmış.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _checkVerificationAndProceed() async {
    await FirebaseAuth.instance.currentUser?.reload();
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && user.emailVerified) {
      try {
        // 🔍 Kullanıcının Firestore'daki verilerini çek
        final snapshot = await FirebaseFirestore.instance
            .collection('users') // Firestore'da koleksiyon ismi
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final userData = snapshot.docs.first.data();
          final myUser = MyAuthModel.fromJson(userData);

          // ✅ FaceAuthPage'e yönlendir ve modeli ver
          Get.offAll(() => FaceAuthPage(userModel: myUser));
        } else {
          Get.snackbar("Kullanıcı Bulunamadı", "Email ile kayıtlı kullanıcı verisi bulunamadı.");
        }
      } catch (e) {
        Get.snackbar("Hata", "Kullanıcı verisi alınırken bir sorun oluştu: $e");
      }
    } else {
      Get.snackbar(
        "Henüz Doğrulanmadı",
        "Lütfen emailinizi kontrol edin ve bağlantıya tıklayın.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Email Doğrulaması Bekleniyor")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_read, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              "Email adresinize bir doğrulama bağlantısı gönderildi.\nLütfen gelen kutunuzu kontrol edin.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),

            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Tekrar Gönder"),
              onPressed: _resendVerificationEmail,
            ),

            const SizedBox(height: 10),

            ElevatedButton.icon(
              icon: const Icon(Icons.verified_user),
              label: const Text("Doğrulandıysa Devam Et"),
              onPressed: _checkVerificationAndProceed,
            ),
          ],
        ),
      ),
    );
  }
}
