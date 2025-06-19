import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppLifecycleController extends WidgetsBindingObserver {
  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached || state == AppLifecycleState.inactive) {
      // Uygulama tamamen kapanıyor (bazı durumlarda background'da da olabilir)
      FirebaseAuth.instance.signOut();
    }
  }
}
