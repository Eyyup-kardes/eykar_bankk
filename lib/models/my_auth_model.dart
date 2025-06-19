import 'account_model.dart';

class MyAuthModel {
  String name;
  String tcNo;
  String email;
  String password;
  String profileImageUrl;
  String phoneNumber;
  List<AccountModel> cashMoney;

  MyAuthModel({
    required this.name,
    required this.tcNo,
    required this.email,
    required this.password,
    required this.profileImageUrl,
    required this.phoneNumber,
    required this.cashMoney,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'tcNo': tcNo,
    'email': email,
    'password': password,
    'profileImageUrl': profileImageUrl,
    'phoneNumber': phoneNumber,
    'cashMoney': cashMoney.map((e) => e.toJson()).toList(),
  };

  factory MyAuthModel.fromJson(Map<String, dynamic> json) {
    final cashMoneyData = json['cashMoney'];
    List<AccountModel> cashMoneyList = [];

    if (cashMoneyData is List) {
      cashMoneyList = cashMoneyData
          .map((e) => AccountModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }


    return MyAuthModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      tcNo: json['tcNo'] ?? '',
      cashMoney: cashMoneyList,
    );
  }

}
