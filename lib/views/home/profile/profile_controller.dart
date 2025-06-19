import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eykar_bank/views/auth/login/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../../models/my_auth_model.dart';

class ProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<MyAuthModel?> user = Rx<MyAuthModel?>(null);

  /// Kullanıcı verisini stream ile al
  Stream<MyAuthModel> get currentUserStream {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => MyAuthModel.fromJson(doc.data()!));
  }

  Future<void> fetchCurrentUser(String tcNo) async {
    try {
      final doc = await _firestore.collection('users').doc(tcNo).get();
      if (doc.exists) {
        user.value = MyAuthModel.fromJson(doc.data()!);
      }
    } catch (e) {
      Get.snackbar('Hata', 'Kullanıcı bilgileri alınamadı: $e');
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updatedData) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore.collection('users').doc(uid).update(updatedData);
      Get.back(); // Geri dön
      Get.snackbar('Başarılı', 'Profil başarıyla güncellendi');
    } catch (e) {
      Get.snackbar('Hata', 'Profil güncellenemedi: $e');
    }
  }

  /// 📷 Galeriden profil resmi değiştir
  Future<void> changeProfileImage() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile == null) {
        Get.snackbar("İptal", "Fotoğraf seçilmedi.");
        return;
      }

      File selected = File(pickedFile.path);
      File? compressed = await _compressImage(selected);

      if (compressed == null) {
        Get.snackbar("Hata", "Görsel sıkıştırılamadı.");
        return;
      }

      // 🔥 Mevcut fotoğrafı sil
      final oldImageUrl = FirebaseAuth.instance.currentUser?.photoURL;
      if (oldImageUrl != null && oldImageUrl.contains("firebase")) {
        try {
          final ref = FirebaseStorage.instance.refFromURL(oldImageUrl);
          await ref.delete();
        } catch (e) {
          print("❌ Eski foto silinemedi: $e");
        }
      }

      // 📤 Yeni fotoğrafı yükle
      final newUrl = await _uploadNewImage(uid, compressed);

      // 🔄 Firestore ve FirebaseAuth güncelle
      await _firestore.collection('users').doc(uid).update({
        'profileImageUrl': newUrl,
      });

      await FirebaseAuth.instance.currentUser?.updatePhotoURL(newUrl);

      Get.snackbar("✅ Başarılı", "Profil fotoğrafı güncellendi.");
    } catch (e) {
      Get.snackbar("Hata", "Fotoğraf değiştirme başarısız: $e");
    }
  }

  /// 🗜️ Fotoğraf sıkıştırma (XFile yerine direkt File döndürür)
  Future<File?> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(dir.path, 'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 60,
    );

    return result != null ? File(result.path) : null;
  }

  /// ☁️ Firebase Storage'a yeni fotoğraf yükleme
  Future<String> _uploadNewImage(String uid, File imageFile) async {
    final ref = FirebaseStorage.instance.ref().child('profile_images').child('$uid.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAll(() => LoginPage()); // Giriş sayfasına yönlendir
    } catch (e) {
      Get.snackbar('Hata', 'Çıkış yapılamadı: $e');
    }
  }
}
