import 'package:flutter/material.dart';
import 'models.dart';
import 'services.dart';

import 'widgets/virtual_card.dart';

class ExpenseController extends ChangeNotifier {
  ExpenseController() {
    initialize();
  }

  final StorageService _storage = StorageService.instance;

  List<TransactionItem> _transactions = [];
  List<VirtualCardData> _cards = [];
  bool _isLoading = true;
  bool _isLocked = false;
  bool _hasPassword = false;
  bool _isPasswordProtectionEnabled = false;
  String _userName = 'Arthur';
  String? _errorMessage;

  List<TransactionItem> get transactions => _transactions;
  List<VirtualCardData> get cards => _cards;
  bool get isLoading => _isLoading;
  bool get isLocked => _isLocked;
  bool get hasPassword => _hasPassword;
  bool get isPasswordProtectionEnabled => _isPasswordProtectionEnabled;
  String get userName => _userName;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await _storage.initialize();

    _userName = _storage.getUserName();
    _transactions = await _storage.getTransactions();

    // Auto-seed initial sample transactions if storage is empty
    if (_transactions.isEmpty) {
      _transactions = _getInitialSampleTransactions();
      await _storage.saveTransactions(_transactions);
    }

    _cards = await _storage.getCards();
    // Auto-seed initial sample cards if storage is empty
    if (_cards.isEmpty) {
      _cards = _getInitialSampleCards();
      await _storage.saveCards(_cards);
    }

    final storedPassword = _storage.getAppPassword();
    _hasPassword = storedPassword != null && storedPassword.isNotEmpty;
    _isPasswordProtectionEnabled = _storage.isPasswordProtectionEnabled();

    // If password is set and enabled, start locked
    if (_hasPassword && _isPasswordProtectionEnabled) {
      _isLocked = true;
    } else {
      _isLocked = false;
    }

    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  // --- Password Protection Actions ---

  Future<bool> unlockApp(String password) async {
    _errorMessage = null;
    final storedPassword = _storage.getAppPassword();

    if (storedPassword == null || storedPassword == password.trim()) {
      _isLocked = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = 'Incorrect password. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<void> setAppPassword(String newPassword) async {
    _errorMessage = null;
    if (newPassword.trim().isEmpty) {
      _errorMessage = 'Password cannot be empty.';
      notifyListeners();
      return;
    }

    await _storage.setAppPassword(newPassword.trim());
    await _storage.setPasswordProtectionEnabled(true);
    _hasPassword = true;
    _isPasswordProtectionEnabled = true;
    _isLocked = false;
    notifyListeners();
  }

  void skipPasswordSetup() {
    _isLocked = false;
    notifyListeners();
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _errorMessage = null;
    final stored = _storage.getAppPassword();
    if (stored != null && stored != currentPassword.trim()) {
      _errorMessage = 'Current password does not match.';
      notifyListeners();
      return false;
    }

    if (newPassword.trim().length < 4) {
      _errorMessage = 'New password must be at least 4 characters.';
      notifyListeners();
      return false;
    }

    await _storage.setAppPassword(newPassword.trim());
    _hasPassword = true;
    _isPasswordProtectionEnabled = true;
    notifyListeners();
    return true;
  }

  Future<bool> togglePasswordProtection(bool enable, {String? currentPassword}) async {
    _errorMessage = null;
    final stored = _storage.getAppPassword();

    // If disabling and a password exists, require current password confirmation
    if (!enable && stored != null) {
      if (currentPassword == null || currentPassword.trim() != stored) {
        _errorMessage = 'Incorrect current password.';
        notifyListeners();
        return false;
      }
    }

    await _storage.setPasswordProtectionEnabled(enable);
    _isPasswordProtectionEnabled = enable;
    notifyListeners();
    return true;
  }

  void lockApp() {
    if (_hasPassword && _isPasswordProtectionEnabled) {
      _isLocked = true;
      notifyListeners();
    }
  }

  Future<void> setUserName(String name) async {
    if (name.trim().isNotEmpty) {
      _userName = name.trim();
      await _storage.setUserName(_userName);
      notifyListeners();
    }
  }

  // --- Transactions CRUD ---

  Future<void> addTransaction(TransactionItem item) async {
    final updated = [..._transactions, item];
    _transactions = updated;
    await _storage.saveTransactions(_transactions);
    notifyListeners();
  }

  Future<void> updateTransaction(TransactionItem updatedItem) async {
    final updated = _transactions.map((item) => item.id == updatedItem.id ? updatedItem : item).toList();
    _transactions = updated;
    await _storage.saveTransactions(_transactions);
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    _transactions = _transactions.where((item) => item.id != id).toList();
    await _storage.saveTransactions(_transactions);
    notifyListeners();
  }

  // --- Virtual Cards CRUD ---

  Future<void> addCard(VirtualCardData card) async {
    _cards = [..._cards, card];
    await _storage.saveCards(_cards);
    notifyListeners();
  }

  Future<void> deleteCard(String id) async {
    _cards = _cards.where((card) => card.id != id).toList();
    await _storage.saveCards(_cards);
    notifyListeners();
  }

  List<VirtualCardData> _getInitialSampleCards() {
    return [
      VirtualCardData(
        id: 'card_seed_1',
        title: 'Main Debit',
        cardNumber: '6175',
        balance: 47417.0,
        brand: 'mastercard',
        gradientIndex: 0,
      ),
      VirtualCardData(
        id: 'card_seed_2',
        title: 'Savings Vault',
        cardNumber: '8820',
        balance: 584400.0,
        brand: 'visa',
        gradientIndex: 1,
      ),
      VirtualCardData(
        id: 'card_seed_3',
        title: 'Travel Platinum',
        cardNumber: '3491',
        balance: 12580.0,
        brand: 'visa',
        gradientIndex: 2,
      ),
    ];
  }

  SummaryStats getSummary() {
    final income = _transactions
        .where((item) => item.type == TransactionType.income)
        .fold<double>(0, (sum, item) => sum + item.amount);
    final expense = _transactions
        .where((item) => item.type == TransactionType.expense)
        .fold<double>(0, (sum, item) => sum + item.amount);

    return SummaryStats(
      totalIncome: income,
      totalExpenses: expense,
      balance: income - expense,
      transactionCount: _transactions.length,
    );
  }

  List<TransactionItem> getRecentTransactions({int limit = 5}) {
    final sorted = [..._transactions]..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(limit).toList();
  }

  List<TransactionItem> filteredTransactions({
    String? type,
    String? category,
    String? search,
  }) {
    final query = search?.toLowerCase().trim() ?? '';
    return _transactions.where((item) {
      final matchesType = type == null || type.isEmpty || type == item.type.label;
      final matchesCategory = category == null || category.isEmpty || item.category == category;
      final matchesSearch = query.isEmpty ||
          item.description.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query);
      return matchesType && matchesCategory && matchesSearch;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<TransactionItem> _getInitialSampleTransactions() {
    final now = DateTime.now();
    return [
      TransactionItem(
        id: 'seed_1',
        type: TransactionType.income,
        amount: 28.11,
        category: 'Food & Beverage',
        description: 'Five Lods',
        date: now.subtract(const Duration(days: 1)),
      ),
      TransactionItem(
        id: 'seed_2',
        type: TransactionType.expense,
        amount: 157.64,
        category: 'Shopping',
        description: 'H&M 1257 ****',
        date: now.subtract(const Duration(days: 2)),
      ),
      TransactionItem(
        id: 'seed_3',
        type: TransactionType.income,
        amount: 4500.00,
        category: 'Salary',
        description: 'Monthly Salary Deposit',
        date: now.subtract(const Duration(days: 4)),
      ),
      TransactionItem(
        id: 'seed_4',
        type: TransactionType.expense,
        amount: 451.00,
        category: 'Bills',
        description: 'Electric & High-Speed Internet',
        date: now.subtract(const Duration(days: 5)),
      ),
      TransactionItem(
        id: 'seed_5',
        type: TransactionType.expense,
        amount: 174.00,
        category: 'Transport',
        description: 'Transit Card & Fuel',
        date: now.subtract(const Duration(days: 6)),
      ),
    ];
  }
}
