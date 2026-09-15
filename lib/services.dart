import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'widgets/virtual_card.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  late SharedPreferences _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Transactions ---

  Future<List<TransactionItem>> getTransactions() async {
    // Try offline_transactions first
    var raw = _prefs.getStringList('offline_transactions');

    // Fallback: check if older transactions exist and migrate them
    if (raw == null) {
      for (final key in _prefs.getKeys()) {
        if (key.startsWith('transactions_')) {
          raw = _prefs.getStringList(key);
          if (raw != null && raw.isNotEmpty) {
            await saveTransactions(raw
                .map((entry) => TransactionItem.fromJson(jsonDecode(entry) as Map<String, dynamic>))
                .toList());
            break;
          }
        }
      }
    }

    if (raw == null) {
      return [];
    }

    return raw
        .map((entry) => TransactionItem.fromJson(jsonDecode(entry) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTransactions(List<TransactionItem> transactions) async {
    final payload = transactions.map((item) => jsonEncode(item.toJson())).toList();
    await _prefs.setStringList('offline_transactions', payload);
  }

  // --- Virtual Cards ---

  Future<List<VirtualCardData>> getCards() async {
    final raw = _prefs.getStringList('offline_virtual_cards');
    if (raw == null) {
      return [];
    }
    return raw
        .map((entry) => VirtualCardData.fromJson(jsonDecode(entry) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCards(List<VirtualCardData> cards) async {
    final payload = cards.map((item) => jsonEncode(item.toJson())).toList();
    await _prefs.setStringList('offline_virtual_cards', payload);
  }

  // --- Password Protection ---

  String? getAppPassword() {
    return _prefs.getString('app_password');
  }

  Future<void> setAppPassword(String? password) async {
    if (password == null || password.isEmpty) {
      await _prefs.remove('app_password');
    } else {
      await _prefs.setString('app_password', password);
    }
  }

  bool isPasswordProtectionEnabled() {
    // If user has set a password, default to enabled unless explicitly disabled
    final hasPassword = getAppPassword() != null;
    return _prefs.getBool('is_password_protection_enabled') ?? hasPassword;
  }

  Future<void> setPasswordProtectionEnabled(bool enabled) async {
    await _prefs.setBool('is_password_protection_enabled', enabled);
  }

  // --- Profile / Personalization ---

  String getUserName() {
    return _prefs.getString('user_name') ?? 'Arthur';
  }

  Future<void> setUserName(String name) async {
    await _prefs.setString('user_name', name.trim());
  }
}
