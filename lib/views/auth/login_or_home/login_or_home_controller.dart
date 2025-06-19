import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../models/my_auth_model.dart';

class LoginOrHomeController extends GetxController {
  final isLoggedIn = false.obs;
  final isEmailVerified = false.obs;
  final currentUser = Rxn<MyAuthModel>();

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      isLoggedIn.value = true;
      isEmailVerified.value = firebaseUser.emailVerified;

      // Firestore'dan kullanıcı verisini çek
      final snapshot = await FirebaseFirestore.instance
          .collection('users') // senin Firestore koleksiyonun
          .where('email', isEqualTo: firebaseUser.email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final userData = snapshot.docs.first.data();
        final myUser = MyAuthModel.fromJson(userData);
        currentUser.value = myUser;
      } else {
        currentUser.value = null;
      }
    } else {
      isLoggedIn.value = false;
    }
  }
}
