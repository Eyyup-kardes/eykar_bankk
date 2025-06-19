import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../hesap/hesap_controller.dart';
import '../transfer/transfer_controller.dart';
import 'select_user_page.dart';
import 'select_to_account_page.dart';

class SelectFromAccountPage extends StatelessWidget {
  const SelectFromAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hesapController = Get.find<HesapController>();
    final transferController = Get.find<TransferController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Para Gönderilecek Hesabı Seç")),
      body: Obx(
            () => ListView.builder(
          itemCount: hesapController.accounts.length,
          itemBuilder: (context, index) {
            final acc = hesapController.accounts[index];
            return ListTile(
              title: Text(acc.name),
              subtitle: Text("${acc.amount.toStringAsFixed(2)} ₺"),
              onTap: () {
                transferController.fromAccountId.value = acc.id;

                if (transferController.isInternalTransfer.value) {
                  Get.to(() => const SelectToAccountPage());
                } else {
                  Get.to(() => const SelectUserPage());
                }
              },
            );
          },
        ),
      ),
    );
  }
}
