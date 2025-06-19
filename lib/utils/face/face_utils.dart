import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class FaceUtils {
  static Future<List<double>?> extractFaceFeaturesFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      final file = File('${(await getTemporaryDirectory()).path}/profile.jpg');
      await file.writeAsBytes(response.bodyBytes);

      final inputImage = InputImage.fromFile(file);
      final detector = FaceDetector(
        options: FaceDetectorOptions(
          enableContours: true,
          enableLandmarks: true,
        ),
      );
      final faces = await detector.processImage(inputImage);
      await detector.close();

      if (faces.isEmpty) return null;
      return getVectorFromFace(faces.first);
    } catch (_) {
      return null;
    }
  }

  static List<double> getVectorFromFace(Face face) {
    final box = face.boundingBox;
    return [box.center.dx, box.center.dy]; // daha gelişmiş vektör yapılabilir
  }

  static double compareFaces(List<double> a, List<double> b) {
    double sum = 0;
    for (int i = 0; i < a.length; i++) {
      sum += (a[i] - b[i]) * (a[i] - b[i]);
    }
    return 1 / (1 + sum); // Euclidean Distance -> similarity
  }
}
