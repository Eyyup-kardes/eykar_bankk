import 'package:eykar_bank/views/home/transfer/transfer_controller.dart';
import 'package:eykar_bank/views/home/homepage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransferSummaryPage extends StatelessWidget {
  const TransferSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransferController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Transfer Özeti")),
      body: Obx(() => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundImage: controller.fromUserPhotoUrl.value.isNotEmpty
                    ? NetworkImage(controller.fromUserPhotoUrl.value)
                    : const AssetImage('assets/default_person.png') as ImageProvider,
              ),
              title: Text("Gönderen: ${controller.fromUserName.value}"),
              subtitle: Text("Hesap ID: ${controller.fromAccountId.value}"),
              trailing: Text("${controller.fromAccountBalance.value.toStringAsFixed(2)} ₺"),
            ),
            ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundImage: controller.toUserPhotoUrl.value.isNotEmpty
                    ? NetworkImage(controller.toUserPhotoUrl.value)
                    : const AssetImage('assets/default_person.png') as ImageProvider,
              ),
              title: Text("Alıcı: ${controller.toUserName.value}"),
              subtitle: Text("Hesap ID: ${controller.toAccountId.value}"),
              trailing: Text("${controller.toAccountBalance.value.toStringAsFixed(2)} ₺"),
            ),
            ListTile(
              title: Text("Tutar: ${controller.amount.value.toStringAsFixed(2)} ₺"),
            ),

            const SizedBox(height: 20),
            controller.isLoading.value
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () async {
                if (controller.isInternalTransfer.value) {
                  await controller.makeInternalTransfer();
                } else {
                  await controller.makeExternalTransferSimple();
                }
                Get.offAll(()=> Homepage()); // Ana sayfaya dön
              },
              child: const Text("Transferi Tamamla"),
            ),
          ],
        ),
      )),
    );
  }
}
