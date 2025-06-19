class AccountModel {
  final String id;
  final String name;
  final double amount;

  AccountModel({
    required this.id,
    required this.name,
    required this.amount,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] ?? '', // id artık array içinden geliyor
      name: json['accountName'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountName': name,
      'amount': amount,
    };
  }
}
