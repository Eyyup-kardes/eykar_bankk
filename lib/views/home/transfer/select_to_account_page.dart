import 'package:eykar_bank/views/home/transfer/transfer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../hesap/hesap_controller.dart';
import 'enter_amount_page.dart';

class SelectToAccountPage extends StatelessWidget {
  const SelectToAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final transferController = Get.find<TransferController>();
    final hesapController = Get.find<HesapController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Para ALacak Hesabı Seç")),
      body: Obx(() {
        if (transferController.isInternalTransfer.value) {
          final myAccounts = hesapController.accounts
              .where((acc) => acc.id != transferController.fromAccountId.value)
              .toList();

          return ListView.builder(
            itemCount: myAccounts.length,
            itemBuilder: (context, index) {
              final acc = myAccounts[index];
              return ListTile(
                title: Text(acc.name),
                subtitle: Text("${acc.amount.toStringAsFixed(2)} ₺"),
                onTap: () {
                  transferController.toAccountId.value = acc.id;
                  Get.to(() => const EnterAmountPage());
                },
              );
            },
          );
        } else {
          return StreamBuilder(
            stream: transferController.firestore
                .collection('users')
                .doc(transferController.otherUserId.value)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text("Hesap bulunamadı"));
              }

              final accounts = List<Map<String, dynamic>>.from(
                  snapshot.data!.get('cashMoney') ?? []);

              return ListView.builder(
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  final acc = accounts[index];
                  return ListTile(
                    title: Text(acc['accountName']),
                    subtitle: Text("${acc['amount']} ₺"),
                    onTap: () {
                      transferController.toAccountId.value = acc['id'];
                      Get.to(() => const EnterAmountPage());
                    },
                  );
                },
              );
            },
          );
        }
      }),
    );
  }
}
