import 'dart:io';
import 'package:eykar_bank/views/auth/otp/phone_number_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';
import '../../../utils/animations/shake_animation.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final AuthController controller = Get.put(AuthController());

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController tcController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 📸 Profil Fotoğrafı
            ShakeTransition(
              delay: Duration(seconds: 1),
              child: Obx(() {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 130,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: controller.profileImagePath.isNotEmpty
                          ? FileImage(File(controller.profileImagePath.value))
                          : null,
                      child: controller.profileImagePath.isEmpty
                          ? const Icon(Icons.person, size: 80, color: Colors.white70)
                          : null,
                    ),
                    // Seçiliyse değiştir
                    if (controller.profileImagePath.isNotEmpty)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () async {
                            await controller.pickImageFromGallery();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
                          ),
                        ),
                      ),

                    // Seçilmemişse tıkla ve ekle
                    if (controller.profileImagePath.isEmpty)
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(100),
                            onTap: () async {
                              await controller.pickImageFromGallery();
                            },
                            child: const Center(
                              child: Text("Fotoğraf Ekle", style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),

            const SizedBox(height: 20),

            // Form Alanları
            ShakeTransition(
              delay: Duration(seconds: 2),
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Ad Soyad'),
                keyboardType: TextInputType.name,
                onChanged: (val) => controller.name.value = val,
              ),
            ),

            ShakeTransition(
              delay: Duration(seconds: 3),
              child: TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                onChanged: (val) => controller.email.value = val,
              ),
            ),

            ShakeTransition(
              delay: Duration(seconds: 4),
              child: TextField(
                controller: passwordController,
                maxLength: 6,
                decoration: const InputDecoration(labelText: 'Şifre'),
                obscureText: true,
                onChanged: (val) => controller.password.value = val,
              ),
            ),

            ShakeTransition(
              delay: Duration(seconds: 5),
              child: TextField(
                controller: tcController,
                decoration: const InputDecoration(labelText: 'TC Kimlik No'),
                keyboardType: TextInputType.number,
                maxLength: 11,
                onChanged: (val) => controller.tcNo.value = val,
              ),
            ),

            ShakeTransition(
              child: TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Telefon (05xx...)'),
                keyboardType: TextInputType.phone,
                maxLength: 11,
                onChanged: (val) => controller.phoneNumber.value = val,
              ),
            ),

            const SizedBox(height: 20),

            ShakeTransition(
              child: Obx(() {
                return controller.isLoading.value
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: () async {
                    bool success = await controller.signUpWithEmail();
                    if (success) {
                      Get.to(() => PhoneNumberPage(phone: phoneController));
                    }
                  },
                  child: const Text("Kayıt Ol"),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
