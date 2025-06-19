import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/my_auth_model.dart';

class LocalStorageService {
  static const _key = 'users';

  static Future<void> saveUser(MyAuthModel model) async {
    final prefs = await SharedPreferences.getInstance();

    // Mevcut kullanıcılar
    final data = prefs.getString(_key);
    Map<String, dynamic> usersMap = data != null ? jsonDecode(data) : {};

    // Yeni kullanıcıyı ekle
    usersMap[model.tcNo] = model.toJson();

    // Tekrar kaydet
    await prefs.setString(_key, jsonEncode(usersMap));
  }

  static Future<List<MyAuthModel>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);

    if (data == null) return [];

    final Map<String, dynamic> usersMap = jsonDecode(data);
    return usersMap.values
        .map((e) => MyAuthModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<MyAuthModel?> getUserByTc(String tcNo) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return null;

    final Map<String, dynamic> usersMap = jsonDecode(data);
    final userData = usersMap[tcNo];
    if (userData == null) return null;

    return MyAuthModel.fromJson(Map<String, dynamic>.from(userData));
  }

  static Future<void> deleteUser(String tcNo) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return;

    Map<String, dynamic> usersMap = jsonDecode(data);
    usersMap.remove(tcNo);

    await prefs.setString(_key, jsonEncode(usersMap));
  }

}
