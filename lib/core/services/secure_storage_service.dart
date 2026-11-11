import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:efootball_clone_hub/models/account_model.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const String _accountsKey = 'efootball_accounts';
  static const String _activeTokenKey = 'active_auth_token';

  static Future<void> saveAuthToken(String token) =>
      _storage.write(key: _activeTokenKey, value: token);

  static Future<String?> getAuthToken() =>
      _storage.read(key: _activeTokenKey);

  static Future<List<AccountModel>> getAccounts() async {
    final data = await _storage.read(key: _accountsKey);
    if (data == null || data.isEmpty) return [];
    try {
      final List decoded = json.decode(data) as List;
      return decoded
          .map((e) => AccountModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveAccounts(List<AccountModel> accounts) async {
    final encoded = json.encode(accounts.map((e) => e.toJson()).toList());
    await _storage.write(key: _accountsKey, value: encoded);
  }

  static Future<void> clearAll() => _storage.deleteAll();
}
