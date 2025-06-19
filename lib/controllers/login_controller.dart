import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/my_auth_model.dart';
import '../services/local_storage_service.dart';

class LoginController extends GetxController {
  final tcNo = ''.obs;
  final password = ''.obs;

  RxList<MyAuthModel> localUsers = <MyAuthModel>[].obs;
  Rx<MyAuthModel?> selectedUser = Rx<MyAuthModel?>(null);

  MyAuthModel? userModel;

  @override
  void onInit() {
    super.onInit();
    loadLocalUsers();
  }

  Future<void> loadLocalUsers() async {
    localUsers.value = await LocalStorageService.getAllUsers();
  }

  Future<void> removeLocalUser(String tcNo) async {
    await LocalStorageService.deleteUser(tcNo);
    await loadLocalUsers(); // listeyi güncelle
  }

  void clearSelectedUser() {
    selectedUser.value = null;
    tcNo.value = '';
    password.value = '';
  }

  Future<bool> loginWithTcAndPassword() async {
    final inputTcNo = selectedUser.value?.tcNo ?? tcNo.value.trim();

    if (inputTcNo.length != 11) {
      Get.snackbar("Hata", "TC Kimlik Numarası 11 haneli olmalıdır");
      return false;
    }

    if (password.value.length != 6) {
      Get.snackbar("Hata", "Şifreniz 6 haneli olmalıdır");
      return false;
    }

    try {
      String email = '';

      if (selectedUser.value != null) {
        // selectedUser doluysa onun emailini kullan
        email = selectedUser.value!.email ?? '';
        if (email.isEmpty) {
          Get.snackbar("Hata", "Seçilen kullanıcının email adresi bulunamadı");
          return false;
        }
      } else {
        // selectedUser boşsa, tcNo ile Firestore'dan email bul
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('tcNo', isEqualTo: inputTcNo)
            .limit(1)
            .get();

        if (snapshot.docs.isEmpty) {
          Get.snackbar("Hatalı Giriş", "Kullanıcı bulunamadı");
          return false;
        }

        final userData = snapshot.docs.first.data();
        email = userData['email'] as String? ?? '';

        if (email.isEmpty) {
          Get.snackbar("Hata", "Kullanıcı email adresi bulunamadı");
          return false;
        }
      }

      // Firebase Auth ile giriş yap
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password.value);


        // Giriş başarılı, userModel güncelle
        if (selectedUser.value != null) {
          userModel = selectedUser.value!;
        } else {
          // Eğer selectedUser boşsa, firestore'dan gelen kullanıcı modelini oluştur
          final snapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('tcNo', isEqualTo: inputTcNo)
              .limit(1)
              .get();
          if (snapshot.docs.isNotEmpty) {
            userModel = MyAuthModel.fromJson(snapshot.docs.first.data());
          }
        }

        User? user = userCredential.user;

        if (user != null && user.emailVerified) {
          // Email doğrulandıysa girişe izin ver
          return true;
        } else {
          // Doğrulanmadıysa uyar
          Get.snackbar("Email Doğrulanmadı",
              "Lütfen email adresinize gelen doğrulama linkine tıklayın.",
              snackPosition: SnackPosition.BOTTOM);
          return false;
        }


        return true;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password') {
          Get.snackbar("Hatalı Giriş", "Şifre yanlış");
        } else if (e.code == 'user-not-found') {
          Get.snackbar("Hatalı Giriş", "Kullanıcı bulunamadı");
        } else {
          Get.snackbar("Hata", e.message ?? "Bilinmeyen hata");
        }
        return false;
      }
    } catch (e) {
      Get.snackbar("Hata", e.toString());
      return false;
    }
  }
}
