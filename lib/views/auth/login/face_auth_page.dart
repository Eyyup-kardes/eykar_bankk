import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:eykar_bank/views/home/homepage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../../models/my_auth_model.dart';

class FaceAuthPage extends StatefulWidget {
  final MyAuthModel userModel;

  const FaceAuthPage({super.key, required this.userModel});

  @override
  State<FaceAuthPage> createState() => _FaceAuthPageState();
}

class _FaceAuthPageState extends State<FaceAuthPage> {
  late CameraController _cameraController;
  bool _isInitialized = false;

  final faceDetector = FaceDetector(
    options: FaceDetectorOptions(enableLandmarks: true, enableContours: true),
  );

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[1], ResolutionPreset.medium);
    await _cameraController.initialize();
    setState(() => _isInitialized = true);
  }

  Future<void> _detectAndCompare() async {
    try {
      // 1. Kameradan fotoğraf çek
      final XFile liveFile = await _cameraController.takePicture();
      final File liveImage = File(liveFile.path);
      final InputImage inputLive = InputImage.fromFile(liveImage);

      // 2. Storage'taki profil fotoğrafını indir
      final Uri url = Uri.parse(widget.userModel.profileImageUrl);
      final http.Response response = await http.get(url);

      if (response.statusCode != 200) {
        Get.snackbar("Hata", "Profil fotoğrafı indirilemedi.");
        return;
      }

      // 3. Geçici dosyaya kaydet
      final tempDir = await getTemporaryDirectory();
      final File storedImage = File('${tempDir.path}/stored_face.jpg');
      await storedImage.writeAsBytes(response.bodyBytes);

      final InputImage inputStored = InputImage.fromFile(storedImage);

      // 4. ML Kit ile yüzleri algıla
      final List<Face> facesLive = await faceDetector.processImage(inputLive);
      final List<Face> facesStored = await faceDetector.processImage(
        inputStored,
      );

      if (facesLive.isEmpty || facesStored.isEmpty) {
        Get.snackbar("Yüz Tanıma", "Her iki görüntüde de yüz algılanamadı.");
        return;
      }

      // 5. Basit bounding box farkı ile eşleştirme
      final face1 = facesLive.first.boundingBox;
      final face2 = facesStored.first.boundingBox;

      final double dx = (face1.center.dx - face2.center.dx).abs();
      final double dy = (face1.center.dy - face2.center.dy).abs();
      final double diff = dx + dy;

      debugPrint('Oran $diff');

      if (diff < 1600) {
        Get.snackbar("Başarılı", "Yüz doğrulandı!");
        Get.offAll(() => Homepage());
      } else {
        Get.snackbar("Başarısız", "Yüz eşleşmedi.");
      }
    } catch (e) {
      Get.snackbar("Hata", "Doğrulama sırasında hata: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Yüz Doğrulama")),
      body: Column(
        children: [
          Expanded(child: CameraPreview(_cameraController)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _detectAndCompare,
            child: const Text("Yüzü Doğrula"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    faceDetector.close();
    super.dispose();
  }
}
