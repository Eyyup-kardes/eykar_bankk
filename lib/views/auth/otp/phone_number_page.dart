import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'otp_controller.dart';

class PhoneNumberPage extends StatelessWidget {
  final TextEditingController phone;
  const PhoneNumberPage({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    final otpController = Get.put(OtpController());
    otpController.phoneNumber.value = phone.text.trim();
    return Scaffold(
      appBar: AppBar(title: Text("Telefon Numarası")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          spacing: 20,
          children: [
            TextField(
              onChanged: (v) => otpController.phoneNumber.value = v,
              controller: phone,
              keyboardType: TextInputType.phone,
              maxLength: 11,
              decoration: InputDecoration(
                labelText: "Telefon Numarası (05..)",
              ),
            ),
            Obx(() {
              return otpController.isLoading1.value
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () => otpController.sendOtp(),
                      child: Text("SMS Gönder"),
                    );
            }),
          ],
        ),
      ),
    );
  }
}
