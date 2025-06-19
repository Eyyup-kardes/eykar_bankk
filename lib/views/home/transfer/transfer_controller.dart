import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransferController extends GetxController {
  final fromAccountId = ''.obs;
  final toAccountId = ''.obs;
  final amount = 0.0.obs;

  final fromUserName = ''.obs;
  final toUserName = ''.obs;

  final fromAccountBalance = 0.0.obs;
  final toAccountBalance = 0.0.obs;

  final isInternalTransfer = true.obs; // true: kendi hesapların arası, false: başka kullanıcı

  final otherUserAccounts = <Map<String, dynamic>>[].obs;
  final otherUserId = ''.obs;

  final isLoading = false.obs;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String get userId => auth.currentUser?.uid ?? '';

  final allUsers = <Map<String, dynamic>>[].obs;

  Stream<List<Map<String, dynamic>>>? _allUsersStream;
  Stream<List<Map<String, dynamic>>>? _otherUserAccountsStream;

  void listenAllUsers() {
    if (_allUsersStream != null) return;

    isLoading.value = true;

    _allUsersStream = firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.id != userId)
          .map((doc) {
        final data = doc.data();
        return {
          'userId': doc.id,
          'name': data['name'] ?? 'İsimsiz Kullanıcı',
          'email': data['email'] ?? 'Bilinmiyor',
          'profileImageUrl': data['profileImageUrl'] ?? '',
          'phoneNumber': data['phoneNumber'] ?? 'Bilinmiyor',
          'cashMoney': data['cashMoney'] ?? [],
        };
      })
          .toList();
    });

    _allUsersStream!.listen((users) {
      allUsers.value = users;
      isLoading.value = false;
    }, onError: (e) {
      isLoading.value = false;
      Get.snackbar('Hata', 'Kullanıcılar alınamadı: $e');
    });
  }

  void listenOtherUserAccounts(String targetUserId) {
    if (_otherUserAccountsStream != null) return;

    isLoading.value = true;
    otherUserId.value = targetUserId;

    _otherUserAccountsStream = firestore
        .collection('users')
        .doc(targetUserId)
        .snapshots()
        .map((docSnapshot) {
      if (!docSnapshot.exists) return <Map<String, dynamic>>[];

      final data = docSnapshot.data();
      if (data == null || data['cashMoney'] == null) return <Map<String, dynamic>>[];

      return List<Map<String, dynamic>>.from(data['cashMoney']);
    });

    _otherUserAccountsStream!.listen((accounts) {
      otherUserAccounts.value = accounts;
      isLoading.value = false;
    }, onError: (e) {
      isLoading.value = false;
      Get.snackbar('Hata', 'Hedef hesaplar alınamadı: $e');
    });
  }

  Future<void> loadUserNamesForSummary() async {
    final fromUserSnapshot = await firestore.collection('users').doc(userId).get();
    final fromUserData = fromUserSnapshot.data();
    fromUserName.value = fromUserData?['name'] ?? 'Bilinmiyor';

    final fromAccounts = List<Map<String, dynamic>>.from(fromUserData?['cashMoney'] ?? []);
    final fromAccount = fromAccounts.firstWhere(
          (acc) => acc['id'] == fromAccountId.value,
      orElse: () => {'amount': 0.0},
    );
    fromAccountBalance.value = (fromAccount['amount'] ?? 0.0).toDouble();

    if (isInternalTransfer.value) {
      toUserName.value = fromUserName.value;

      final toAccount = fromAccounts.firstWhere(
            (acc) => acc['id'] == toAccountId.value,
        orElse: () => {'amount': 0.0},
      );
      toAccountBalance.value = (toAccount['amount'] ?? 0.0).toDouble();
    } else {
      final toUserSnapshot = await firestore.collection('users').doc(otherUserId.value).get();
      final toUserData = toUserSnapshot.data();
      toUserName.value = toUserData?['name'] ?? 'Bilinmiyor';

      final toAccounts = List<Map<String, dynamic>>.from(toUserData?['cashMoney'] ?? []);
      final toAccount = toAccounts.firstWhere(
            (acc) => acc['id'] == toAccountId.value,
        orElse: () => {'amount': 0.0},
      );
      toAccountBalance.value = (toAccount['amount'] ?? 0.0).toDouble();
    }
  }


  Future<void> makeInternalTransfer() async {
    if (!_validateTransferInputs(internal: true)) return;

    isLoading.value = true;
    final docRef = firestore.collection('users').doc(userId);

    try {
      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        final data = snapshot.data();
        if (data == null || data['cashMoney'] == null) throw Exception("Hesap verisi bulunamadı");

        List<dynamic> accounts = List.from(data['cashMoney']);

        int fromIndex = accounts.indexWhere((acc) => acc['id'] == fromAccountId.value);
        int toIndex = accounts.indexWhere((acc) => acc['id'] == toAccountId.value);

        if (fromIndex == -1 || toIndex == -1) throw Exception("Hesaplar bulunamadı");

        double fromBalance = (accounts[fromIndex]['amount'] ?? 0).toDouble();
        if (fromBalance < amount.value) throw Exception("Yetersiz bakiye");

        accounts[fromIndex]['amount'] = fromBalance - amount.value;
        accounts[toIndex]['amount'] = (accounts[toIndex]['amount'] ?? 0).toDouble() + amount.value;

        transaction.update(docRef, {'cashMoney': accounts});
      });

      _resetForm();
      Get.snackbar("Başarılı", "Hesaplar arası transfer tamamlandı.");
    } catch (e) {
      Get.snackbar("Hata", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> makeExternalTransferSimple() async {
    if (!_validateTransferInputs(internal: false)) return;

    isLoading.value = true;
    final fromDocRef = firestore.collection('users').doc(userId);
    final toDocRef = firestore.collection('users').doc(otherUserId.value);

    try {
      final fromSnapshot = await fromDocRef.get();
      final fromData = fromSnapshot.data();
      List<dynamic> fromAccounts = List.from(fromData?['cashMoney'] ?? []);
      int fromIndex = fromAccounts.indexWhere((acc) => acc['id'] == fromAccountId.value);
      double fromBalance = (fromAccounts[fromIndex]['amount'] ?? 0).toDouble();

      if (fromBalance < amount.value) throw Exception("Yetersiz bakiye");

      fromAccounts[fromIndex]['amount'] = fromBalance - amount.value;
      await fromDocRef.update({'cashMoney': fromAccounts});

      final toSnapshot = await toDocRef.get();
      final toData = toSnapshot.data();
      List<dynamic> toAccounts = List.from(toData?['cashMoney'] ?? []);
      int toIndex = toAccounts.indexWhere((acc) => acc['id'] == toAccountId.value);
      double toBalance = (toAccounts[toIndex]['amount'] ?? 0).toDouble();

      toAccounts[toIndex]['amount'] = toBalance + amount.value;
      await toDocRef.update({'cashMoney': toAccounts});

      _resetForm();
      Get.snackbar("Başarılı", "Başka hesaba transfer tamamlandı.");
    } catch (e) {
      Get.snackbar("Hata", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateTransferInputs({required bool internal}) {
    if (userId.isEmpty) {
      Get.snackbar("Hata", "Kullanıcı girişi yok.");
      return false;
    }

    if (amount.value <= 0) {
      Get.snackbar("Hata", "Transfer miktarı 0'dan büyük olmalıdır.");
      return false;
    }

    if (fromAccountId.value.isEmpty || toAccountId.value.isEmpty) {
      Get.snackbar("Hata", "Hesaplar seçilmedi.");
      return false;
    }

    if (internal) {
      if (fromAccountId.value == toAccountId.value) {
        Get.snackbar("Hata", "Aynı hesaplar arasında transfer yapılamaz.");
        return false;
      }
    } else {
      if (otherUserId.value.isEmpty) {
        Get.snackbar("Hata", "Hedef kullanıcı seçilmedi.");
        return false;
      }
    }

    return true;
  }

  void _resetForm() {
    fromAccountId.value = '';
    toAccountId.value = '';
    amount.value = 0.0;
    otherUserAccounts.clear();
    otherUserId.value = '';
  }

  @override
  void onClose() {
    super.onClose();
    // Stream subscriptionları eğer elle tutuluyorsa burada cancel edilebilir.
  }
}
