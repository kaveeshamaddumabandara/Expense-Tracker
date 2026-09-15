import 'package:flutter/material.dart';

enum TransactionType { income, expense }

extension TransactionTypeExtension on TransactionType {
  String get label {
    switch (this) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
    }
  }

  Color get color {
    switch (this) {
      case TransactionType.income:
        return const Color(0xFF10B981);
      case TransactionType.expense:
        return const Color(0xFFEF4444);
    }
  }
}

TransactionType parseTransactionType(String value) {
  return value.toLowerCase() == 'income' ? TransactionType.income : TransactionType.expense;
}

class TransactionItem {
  TransactionItem({
    required this.id,
    this.userId = 'local',
    required this.type,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
  });

  final String id;
  final String userId;
  final TransactionType type;
  final double amount;
  final String category;
  final String description;
  final DateTime date;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'type': type.label,
        'amount': amount,
        'category': category,
        'description': description,
        'date': date.toIso8601String(),
      };

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'] as String,
      userId: (json['userId'] as String?) ?? 'local',
      type: parseTransactionType(json['type'] as String),
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }
}

class SummaryStats {
  SummaryStats({
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.transactionCount,
  });

  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final int transactionCount;
}
