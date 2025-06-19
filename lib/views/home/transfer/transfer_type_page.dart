import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eykar_bank/views/home/transfer/select_from_account_page.dart';
import 'package:eykar_bank/views/home/transfer/transfer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransferTypePage extends StatelessWidget {
  const TransferTypePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TransferController());
    return Scaffold(
      appBar: AppBar(title: Text('Para Transferi')),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Card(
              color: Colors.grey,
              child: ListTile(
                title: Text('Hesaplarım Arası Transfer'),
                onTap: () {
                  controller.isInternalTransfer.value = true;
                  Get.to(() => SelectFromAccountPage());
                },
              ),
            ),
            Card(
              color: Colors.grey,
              child: ListTile(
                title: Text('Başka Hesaba Transfer'),
                onTap: () {
                  controller.isInternalTransfer.value = false;
                  Get.to(() => SelectFromAccountPage());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
