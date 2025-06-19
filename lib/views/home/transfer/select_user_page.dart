import 'package:eykar_bank/views/home/transfer/transfer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'select_to_account_page.dart';

class SelectUserPage extends StatelessWidget {
  const SelectUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransferController>();
    controller.listenAllUsers();

    return Scaffold(
      appBar: AppBar(title: const Text("Kullanıcı Seç")),
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());

        return ListView.builder(
          itemCount: controller.allUsers.length,
          itemBuilder: (context, index) {
            final user = controller.allUsers[index];
            return ListTile(
              title: Text(user['name']),
              subtitle: Text(user['email']),
              onTap: () {
                controller.otherUserId.value = user['userId'];
                Get.to(() => const SelectToAccountPage());
              },
            );
          },
        );
      }),
    );
  }
}
