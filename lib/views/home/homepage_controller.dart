import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eykar_bank/views/home/hesap/hesap_page.dart';
import 'package:eykar_bank/views/home/settings/settings_page.dart';
import 'package:eykar_bank/views/home/transfer/transfer_type_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/my_auth_model.dart';
import 'profile/profile_page.dart';

class HomepageController extends GetxController{

  RxInt currentIndex = 0.obs;
  final FirebaseAuth auth = FirebaseAuth.instance;

  void changeTab(int index) {
    currentIndex.value = index;
  }

  final List<Widget> pages = [
    HesapPage(),
    const TransferTypePage(),
    const SettingsPage(),
    const ProfilePage(),
  ];

  /// Kullanıcı verisini stream ile al
  Stream<MyAuthModel> get currentUserStream {
    final uid = auth.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => MyAuthModel.fromJson(doc.data()!));
  }

}