import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> authenticateWithBiometrics() async {
    final bool canCheckBiometrics = await auth.canCheckBiometrics;
    final bool isDeviceSupported = await auth.isDeviceSupported();

    if (!canCheckBiometrics || !isDeviceSupported) {
      return false;
    }

    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Lütfen kimliğinizi doğrulayın',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return didAuthenticate;
    } catch (e) {
      print('Biometric auth error: $e');
      return false;
    }
  }
}
