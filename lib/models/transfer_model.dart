class TransferModel {
  final String id; // Transfer işleminin ID’si (Firestore doküman ID’si)
  final String fromAccountId;
  final String toAccountId;
  final double amount;
  final DateTime date;

  TransferModel({
    required this.id,
    required this.fromAccountId,
    required this.toAccountId,
    required this.amount,
    required this.date,
  });

  factory TransferModel.fromJson(Map<String, dynamic> json, String docId) {
    return TransferModel(
      id: docId,
      fromAccountId: json['fromAccountId'] ?? '',
      toAccountId: json['toAccountId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromAccountId': fromAccountId,
      'toAccountId': toAccountId,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }
}
