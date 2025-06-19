import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../models/account_model.dart';

class HesapController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kullanıcı ID
  String get userId => _auth.currentUser?.uid ?? '';

  /// Observable hesap listesi
  final RxList<AccountModel> accounts = <AccountModel>[].obs;


  /// Toplam para observable
  final RxDouble totalCash = 0.0.obs;

  @override
  void onInit() {
    super.onInit();

    /// Hesapları dinle ve accounts listesine aktar
    if (userId.isNotEmpty) {
      accountStream.listen((list) {
        accounts.value = list;
      });

      cashMoneyStream.listen((value) {
        totalCash.value = value;
      });
    }
  }

  @override
  void onReady() {
    super.onReady();

    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _listenToUserAccounts();
      } else {
        accounts.clear();
        totalCash.value = 0.0;
      }
    });
  }

  // Toplam para stream'i
  Stream<double> get cashMoneyStream =>
      accountStream.map((accounts) => accounts.fold(0.0, (sum, item) => sum + (item.amount ?? 0.0)));

  StreamSubscription? _accountSub;

  void _listenToUserAccounts() {
    _accountSub?.cancel();

    _accountSub = _firestore.collection('users').doc(userId).snapshots().listen((doc) {
      final data = doc.data();
      if (data != null && data['cashMoney'] != null) {
        final List<dynamic> rawList = data['cashMoney'];
        final parsed = rawList.map((e) => AccountModel.fromJson(Map<String, dynamic>.from(e))).toList();
        accounts.value = parsed;
        totalCash.value = parsed.fold(0.0, (sum, item) => sum + (item.amount ?? 0.0));
      } else {
        accounts.clear();
        totalCash.value = 0.0;
      }
    });
  }



  /// Firebase stream'den hesapları dinle
  Stream<List<AccountModel>> get accountStream {
    if (userId.isEmpty) return const Stream.empty();
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      final data = doc.data();
      if (data != null && data['cashMoney'] != null) {
        final List<dynamic> rawList = data['cashMoney'];
        return rawList.map((e) => AccountModel.fromJson(Map<String, dynamic>.from(e))).toList();
      }
      return [];
    });
  }

  Future<void> addAccount({required String name, required double money}) async {
    if (userId.isEmpty) return;
    final docRef = _firestore.collection('users').doc(userId);
    final snapshot = await docRef.get();
    final List<dynamic> currentList = snapshot.data()?['cashMoney'] ?? [];
    currentList.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'userId': userId,
      'accountName': name,
      'amount': money,
    });
    await docRef.set({'cashMoney': currentList}, SetOptions(merge: true));
  }


  Future<void> deleteAccount(int index) async {
    if (userId.isEmpty) return;
    final docRef = _firestore.collection('users').doc(userId);
    final snapshot = await docRef.get();
    final List<dynamic> currentList = snapshot.data()?['cashMoney'] ?? [];
    if (index < currentList.length) {
      currentList.removeAt(index);
      await docRef.update({'cashMoney': currentList});
    }
  }

  Future<void> updateAccountName({required int index, required String newName}) async {
    if (userId.isEmpty) return;
    final docRef = _firestore.collection('users').doc(userId);
    final snapshot = await docRef.get();
    final List<dynamic> currentList = snapshot.data()?['cashMoney'] ?? [];
    if (index < currentList.length) {
      final updated = Map<String, dynamic>.from(currentList[index]);
      updated['accountName'] = newName;
      currentList[index] = updated;
      await docRef.update({'cashMoney': currentList});
    }
  }


  Future<List<AccountModel>> fetchAllUserAccountsExcludingCurrent() async {
    if (userId.isEmpty) return [];
    final querySnapshot = await _firestore.collection('users').get();
    List<AccountModel> allAccounts = [];
    for (var doc in querySnapshot.docs) {
      if (doc.id == userId) continue;
      final data = doc.data();
      if (data['cashMoney'] != null) {
        final rawList = List<Map<String, dynamic>>.from(
            (data['cashMoney'] as List).map((e) => Map<String, dynamic>.from(e)));
        allAccounts.addAll(rawList.map((e) => AccountModel.fromJson(e)));
      }
    }
    return allAccounts;
  }

  @override
  void onClose() {
    _accountSub?.cancel();
    super.onClose();
  }

}
