import 'package:eykar_bank/views/auth/login/face_auth_page.dart';
import 'package:eykar_bank/views/auth/register/register_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controller.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final controller = Get.put(LoginController());

  final tcController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('Giriş Yap'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Get.bottomSheet(
                Container(
                  color: Colors.white,
                  child: Obx(() {
                    final users = controller.localUsers;
                    if (users.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text("Kayıtlı kullanıcı bulunamadı"),
                      );
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...users.map((user) => ListTile(
                          title: Text(user.name),
                          subtitle: Text(user.tcNo),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () async {
                              await controller.removeLocalUser(user.tcNo);
                              Get.snackbar("Silindi", "${user.name} adlı kullanıcı kaldırıldı.");
                            },
                          ),
                          onTap: () {
                            controller.selectedUser.value = user;
                            controller.tcNo.value = user.tcNo;
                            Get.back();
                          },
                        )),
                        const Divider(),
                        ListTile(
                          leading:
                          const Icon(Icons.delete, color: Colors.red),
                          title: const Text("Seçili Kullanıcıyı Kaldır"),
                          onTap: () {
                            controller.clearSelectedUser();
                            Get.back();
                          },
                        ),
                      ],
                    );
                  }),
                ),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final selected = controller.selectedUser.value;

          if (selected != null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("📍 Seçilen Profil", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Text("👤 ${selected.name}", style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  maxLength: 6,
                  decoration: const InputDecoration(labelText: 'Şifre'),
                  obscureText: true,
                  onChanged: (val) => controller.password.value = val,
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Get.to(() => RegisterPage());
                    },
                    child: Text('Kayıt Ol'),
                  ),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () async {
                      bool success = await controller.loginWithTcAndPassword();
                      if (success) {
                        Get.to(() => FaceAuthPage(userModel: controller.userModel!));
                      }
                    },
                    child: const Text('Giriş Yap'),
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                TextField(
                  controller: tcController,
                  decoration: const InputDecoration(labelText: 'TC Kimlik No'),
                  keyboardType: TextInputType.number,
                  maxLength: 11,
                  onChanged: (val) => controller.tcNo.value = val,
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Şifre'),
                  maxLength: 6,
                  obscureText: true,
                  onChanged: (val) => controller.password.value = val,
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Get.to(() => RegisterPage());
                    },
                    child: Text('Kayıt Ol'),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () async {
                      bool success = await controller.loginWithTcAndPassword();
                      if (success) {
                        Get.to(() => FaceAuthPage(userModel: controller.userModel!));
                      }
                    },
                    child: const Text('Giriş Yap'),
                  ),
                ),
              ],
            );
          }
        }),
      ),
    );
  }
}
