import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'hesap_controller.dart';

class HesapPage extends StatelessWidget {
  HesapPage({super.key});

  final hesapController = Get.put(HesapController());
  final nameController = TextEditingController();
  final moneyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Hesaplarım")),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Obx(() => Text(
                "Toplam Para: ${hesapController.totalCash.value.toStringAsFixed(2)}₺",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Hesap Adı"),
              ),
              TextField(
                controller: moneyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Para (₺)"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final money = double.tryParse(moneyController.text.trim()) ?? 0.0;
                  if (name.isNotEmpty && money > 0) {
                    await hesapController.addAccount(name: name, money: money);
                    nameController.clear();
                    moneyController.clear();
                  }
                },
                child: const Text("Hesap Ekle"),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Obx(() => Expanded(
                child: ListView.builder(
                  itemCount: hesapController.accounts.length,
                  itemBuilder: (context, index) {
                    final acc = hesapController.accounts[index];
                    return ListTile(
                      title: Text(acc.name),
                      trailing: Text("${acc.amount?.toStringAsFixed(2) ?? '0.00'}₺"),
                      onTap: () async {
                        final editNameController = TextEditingController(text: acc.name);
                        final newName = await Get.dialog<String?>(
                          AlertDialog(
                            title: const Text("Hesap Adını Düzenle"),
                            content: TextField(
                              controller: editNameController,
                              decoration: const InputDecoration(labelText: "Yeni Hesap Adı"),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text("İptal"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  final enteredName = editNameController.text.trim();
                                  if (enteredName.isNotEmpty) Get.back(result: enteredName);
                                },
                                child: const Text("Kaydet"),
                              ),
                            ],
                          ),
                        );
                        if (newName != null && newName.isNotEmpty) {
                          await hesapController.updateAccountName(index: index, newName: newName);
                        }
                      },
                      onLongPress: () async {
                        Get.defaultDialog(
                          title: "Hesap Sil",
                          middleText: "Bu hesabı silmek istediğinize emin misiniz?",
                          confirm: ElevatedButton(
                            onPressed: () async {
                              await hesapController.deleteAccount(index);
                              Get.back();
                            },
                            child: const Text("Evet"),
                          ),
                          cancel: ElevatedButton(
                            onPressed: () => Get.back(),
                            child: const Text("Hayır"),
                          ),
                        );
                      },
                    );
                  },
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
