import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../views/auth/login_or_home/app_lifecycle.dart';
import '../firebase/firebase_options.dart';

class PreMain {
  static Future<void> preMain() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Duplicate initialize kontrolü (FirebaseApp varsa tekrar başlatma)
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    final lifecycleController = AppLifecycleController();
    lifecycleController.init();
  }
}
