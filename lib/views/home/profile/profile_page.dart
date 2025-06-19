import 'package:eykar_bank/views/home/hesap/hesap_controller.dart';
import 'package:eykar_bank/views/home/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.put(ProfileController());
    final hesapController = Get.put(HesapController());


    return Center(
      child: StreamBuilder(
        stream: profileController.currentUserStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Hata: ${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return Column(
              children: [
                Text('Kullanıcı verisi bulunamadı'),
                ElevatedButton(
                  onPressed: () async{
                    await profileController.signOut();
                    Get.offAll(()=> LoginPage());
                  },
                  child: const Text('Çıkış Yap'),
                ),
              ],
            );
          }

          final userData = snapshot.data;

          return Scaffold(
            appBar: AppBar(
              title: Text(userData!.name),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await profileController.signOut();
                    Get.offAll(() => LoginPage());
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 180,
                      backgroundImage: NetworkImage(userData!.profileImageUrl),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await profileController.changeProfileImage();
                      },
                      icon: Icon(Icons.photo_camera_back_outlined),
                      label: Text("Fotoğrafı Değiştir"),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Ad: ${userData.name}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Toplam Para: ${hesapController.totalCash.value.toStringAsFixed(2)}₺",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'E-posta: ${userData.email}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Telefon: ${userData.phoneNumber}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'TC Kimlik No: ${userData.tcNo}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Parola: ${userData.password}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async{
                        await profileController.fetchCurrentUser(userData.tcNo);

                        final nameController = TextEditingController(text: userData.name);
                        final emailController = TextEditingController(text: userData.email);
                        final phoneController = TextEditingController(text: userData.phoneNumber);
                        final passwordController = TextEditingController(text: userData.password);

                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Profili Güncelle'),
                              content: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: nameController,
                                      keyboardType: TextInputType.name,
                                      decoration: const InputDecoration(labelText: 'Ad'),
                                    ),
                                    TextField(
                                      controller: emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: const InputDecoration(labelText: 'Email'),
                                    ),
                                    TextField(
                                      controller: phoneController,
                                      keyboardType: TextInputType.phone,
                                      maxLength: 11,
                                      decoration: const InputDecoration(labelText: 'Telefon'),
                                    ),
                                    TextField(
                                      controller: passwordController,
                                      keyboardType: TextInputType.visiblePassword,
                                      decoration: const InputDecoration(labelText: 'Parola'),
                                      obscureText: true,
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('İptal'),
                                ),
                                ElevatedButton(
                                  onPressed: () async{
                                   await profileController.updateProfile({
                                      'name': nameController.text.trim(),
                                      'email': emailController.text.trim(),
                                      'phoneNumber': phoneController.text.trim(),
                                      'password': passwordController.text.trim(),
                                    });
                                  },
                                  child: const Text('Kaydet'),
                                ),
                              ],
                            );
                          },
                        );

                      },
                      child: const Text('Profili Güncelle'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
