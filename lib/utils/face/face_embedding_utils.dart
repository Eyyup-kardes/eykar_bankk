import 'dart:typed_data';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceEmbeddingUtils {
  static late Interpreter _interpreter;

  static Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('facenet.tflite');
  }

  // Yüzü tespit ettikten sonra burayı kullan, yüzü kesip ver
  static Float32List imageToFloat32List(img.Image image) {
    final Float32List convertedBytes = Float32List(160 * 160 * 3);
    int bufferIndex = 0;

    for (int y = 0; y < 160; y++) {
      for (int x = 0; x < 160; x++) {
        final pixel = image.getPixel(x, y);

        final r = pixel.r; // veya pixel.red
        final g = pixel.g;
        final b = pixel.b;

        convertedBytes[bufferIndex++] = (r - 128) / 128;
        convertedBytes[bufferIndex++] = (g - 128) / 128;
        convertedBytes[bufferIndex++] = (b - 128) / 128;
      }
    }

    return convertedBytes;
  }



  // Fotoğraftan embedding çıkar
  static Future<List<double>?> getFaceEmbedding(img.Image faceImage) async {
    if (_interpreter == null) return null;

    final input = imageToFloat32List(faceImage).reshape([1, 160, 160, 3]);
    final output = List.filled(128, 0).reshape([1, 128]);

    _interpreter.run(input, output);

    return List<double>.from(output[0]);
  }

  static double cosineSimilarity(List<double> a, List<double> b) {
    double dot = 0.0, normA = 0.0, normB = 0.0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    return dot / (sqrt(normA) * sqrt(normB));
  }
}
