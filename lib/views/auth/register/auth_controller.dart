import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import '../../../models/account_model.dart';
import '../../../models/my_auth_model.dart';
import '../../../services/local_storage_service.dart';
import '../login/login_controller.dart';

class AuthController extends GetxController {
  RxBool isLoading = false.obs;

  final name = ''.obs;
  final email = ''.obs;
  final password = ''.obs;
  final profileImagePath = ''.obs;
  final profileImageUrl = ''.obs;
  final phoneNumber = ''.obs;
  final tcNo = ''.obs;

  CameraController? cameraController;

  /// 📷 Kamerayı başlatır
  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    final frontCam = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.front,
    );

    cameraController = CameraController(frontCam, ResolutionPreset.ultraHigh);
    await cameraController!.initialize();
  }

  // 📁 Galeriden fotoğraf seçme
  Future<void> pickImageFromGallery() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final compressedFile = await compressImage(file);
        if (compressedFile != null) {
          profileImagePath.value = compressedFile.path;
        } else {
          Get.snackbar("Hata", "Resim sıkıştırılamadı");
        }
      } else {
        Get.snackbar("İptal", "Fotoğraf seçilmedi");
      }
    } catch (e) {
      Get.snackbar("Hata", "Galeri açılırken bir hata oluştu: $e");
    }
  }

  /// 📸 Kamera ile fotoğraf çek
  Future<void> captureProfileImage() async {
    try {
      if (cameraController == null || !cameraController!.value.isInitialized) {
        await initializeCamera();
      }

      final picture = await cameraController!.takePicture();
      final flippedFile = await _flipImage(File(picture.path));
      final compressedFile = await compressImage(flippedFile);

      if (compressedFile != null) {
        profileImagePath.value = compressedFile.path;
      } else {
        Get.snackbar("Hata", "Resim sıkıştırılamadı");
      }
    } catch (e) {
      Get.snackbar("Kamera Hatası", e.toString());
    }
  }

  /// 🪞 Fotoğrafı yatayda çevir (ayna)
  Future<File> _flipImage(File originalFile) async {
    final bytes = await originalFile.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return originalFile;

    final flipped = img.flipHorizontal(image);
    final dir = await getTemporaryDirectory();
    final flippedPath = path.join(
      dir.path,
      'flipped_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    final flippedFile = File(flippedPath)
      ..writeAsBytesSync(img.encodeJpg(flipped));
    return flippedFile;
  }

  /// 🗜️ Resmi sıkıştır
  Future<XFile?> compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = path.join(
      dir.path,
      '${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 60,
    );

    return result;
  }

  /// ☁️ Fotoğrafı Storage'a yükle
  Future<String> uploadProfileImage(String uid) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child('$uid.jpg');
    final uploadTask = await ref.putFile(File(profileImagePath.value));
    return await ref.getDownloadURL();
  }

  /// 🧾 Email ve şifre ile kayıt
  Future<bool> signUpWithEmail() async {
    if (profileImagePath.isEmpty) {
      Get.snackbar("⚠️ Eksik Bilgi", "Lütfen profil fotoğrafınızı ekleyin");
      return false;
    }

    // 🔍 Yüz kontrolü
    final hasFace = await detectFaceInProfileImage();
    if (!hasFace) {
      Get.snackbar(
        "🚫 Yüz Algılanamadı",
        "Profil fotoğrafınızda yüz algılanmadı. Lütfen net bir yüz fotoğrafı yükleyin.",
      );
      return false;
    }

    if (password.value.length != 6) {
      Get.snackbar(
        "⚠️ Eksik Bilgi",
        "Lütfen Şifrenizi 6 haneli olarak ekleyin",
      );
      return false;
    }

    if (tcNo.value.length != 11) {
      Get.snackbar(
        "⚠️ Eksik Bilgi",
        "Lütfen geçerli bir 11 Haneli TC Kimlik No girin",
      );
      return false;
    }

    if (phoneNumber.value.length != 11) {
      Get.snackbar(
        "⚠️ Eksik Bilgi",
        "Lütfen geçerli bir 11 Haneli Telefon No girin",
      );
      return false;
    }

    try {
      isLoading.value = true;

      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email.value,
            password: password.value,
          );

      final uid = credential.user!.uid;

      User? user = credential.user;

      // Email doğrulama linki gönder
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();

        // Uyarı ver: Email gönderildi
        Get.snackbar(
          "Doğrulama Gönderildi",
          "Email adresinize doğrulama bağlantısı gönderildi. Lütfen emailinizi kontrol edin.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      // Fotoğrafı yükle
      final url = await uploadProfileImage(uid);
      profileImageUrl.value = url;
      await credential.user?.updatePhotoURL(url);

      await credential.user?.updateDisplayName(name.value);

      final userData = MyAuthModel(
        name: name.value,
        email: email.value,
        password: password.value,
        profileImageUrl: profileImageUrl.value,
        phoneNumber: phoneNumber.value,
        tcNo: tcNo.value,
        cashMoney: [
          AccountModel(
            name: 'Vadesiz Hesap',
            amount: 100.00,
            id: 'vadesiz_${DateTime.now().millisecondsSinceEpoch}',
          ),
        ],
      );

      // ✅ Local'e kaydet
      await LocalStorageService.saveUser(userData);

      // ✅ Firestore'a kaydet
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(userData.toJson());

      // ✅ LoginController'daki local listeyi güncelle
      final loginController = Get.isRegistered<LoginController>()
          ? Get.find<LoginController>()
          : null;

      await loginController?.loadLocalUsers();

      Get.snackbar("✅ Kayıt Başarılı", "Email ve bilgileriniz kaydedildi");
      return true;
    } catch (e) {
      Get.snackbar("❌ Kayıt Hatası", e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> detectFaceInProfileImage() async {
    try {
      final imagePath = profileImagePath.value;
      final inputImage = InputImage.fromFilePath(imagePath);

      final faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableContours: true,
          enableLandmarks: true,
        ),
      );

      final faces = await faceDetector.processImage(inputImage);
      await faceDetector.close();

      return faces.isNotEmpty;
    } catch (e) {
      Get.snackbar(
        "Yüz Algılama Hatası",
        "Resimde yüz kontrol edilirken hata: $e",
      );
      return false;
    }
  }
}
