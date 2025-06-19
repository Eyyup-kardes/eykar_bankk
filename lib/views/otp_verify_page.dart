import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/otp_controller.dart';

class OtpVerifyPage extends StatelessWidget {
  final otpController = Get.find<OtpController>();
  final codeController = TextEditingController();

  OtpVerifyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SMS Doğrulama")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: codeController,
              decoration: InputDecoration(labelText: "Doğrulama Kodu"),
              maxLength: 6,
              keyboardType: TextInputType.number,
            ),
            Obx(() {
              return otpController.isLoading2.value
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () =>
                          otpController.verifyOtp(codeController.text.trim()),
                      child: Text("Doğrula"),
                    );
            }),
          ],
        ),
      ),
    );
  }
}
