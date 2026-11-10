import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/account_model.dart';

class SecureStorageService {
  static const _secureStorage = FlutterSecureStorage();
  static const String _accountsKey = 'encrypted_efootball_accounts';
  static const String _activeTokenKey = 'active_auth_token';

  // ذخیره امن توکن ورود واقعی
  static Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: _activeTokenKey, value: token);
  }

  static Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: _activeTokenKey);
  }

  // مدیریت لیست حساب‌ها به صورت ایزوله
  static Future<List<AccountModel>> getAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_accountsKey);
    if (data == null) return [];
    
    final List decoded = json.decode(data);
    return decoded.map((item) => AccountModel.fromJson(item)).toList();
  }

  static Future<void> saveAccounts(List<AccountModel> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(accounts.map((e) => e.toJson()).toList());
    await prefs.setString(_accountsKey, encoded);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _secureStorage.deleteAll();
  }
}
