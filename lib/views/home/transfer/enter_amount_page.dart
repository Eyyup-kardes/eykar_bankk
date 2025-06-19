import 'package:eykar_bank/views/home/transfer/transfer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'transfer_summary_page.dart';

class EnterAmountPage extends StatelessWidget {
  const EnterAmountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransferController>();
    final amountController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Tutar Gir")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Transfer Tutarı (₺)"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final entered = double.tryParse(amountController.text) ?? 0.0;
                if (entered > 0) {
                  controller.amount.value = entered;
                  Get.to(() => const TransferSummaryPage());
                } else {
                  Get.snackbar("Hata", "Geçerli bir tutar girin");
                }
              },
              child: const Text("İlerle"),
            ),
          ],
        ),
      ),
    );
  }
}
