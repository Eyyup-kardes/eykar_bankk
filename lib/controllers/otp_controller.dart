import 'package:eykar_bank/views/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../views/otp_verify_page.dart';

class OtpController extends GetxController {
  final phoneNumber = ''.obs;
  String _verificationId = '';

  RxBool isLoading1 = false.obs;
  RxBool isLoading2 = false.obs;

  Future<void> sendOtp() async {

    isLoading1.value = true;

    if(phoneNumber.value.length < 11) {
      Get.snackbar("Hata", "Lütfen 11 haneli bir telefon numarası girin.");
      return;
    }

    try{

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+9${phoneNumber.value}',
        verificationCompleted: (phoneAuthCredential) {},
        verificationFailed: (e) {
          Get.snackbar("Doğrulama Hatası", e.message ?? '');
        },
        codeSent: (verificationId, _) {
          _verificationId = verificationId;
          Get.to(() => OtpVerifyPage());
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      Get.snackbar("Hata", e.toString());
    } finally {
      isLoading1.value = false;
    }
  }

  Future<void> verifyOtp(String code) async {
    if(code.length < 6) {
      Get.snackbar("Hata", "Lütfen 6 haneli doğrulama kodu girin.");
    }


    final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId, smsCode: code);
    try {
      isLoading2.value = true;
      await FirebaseAuth.instance.currentUser?.linkWithCredential(credential);
      Get.offAll(()=> LoginPage());
      Get.snackbar("Başarılı", "Telefon numarası doğrulandı!");
    } catch (e) {
      Get.snackbar("Hata", e.toString());
    } finally {
      isLoading2.value = false;
    }
  }
}
