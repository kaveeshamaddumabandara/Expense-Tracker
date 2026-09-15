import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controller.dart';
import '../models.dart';
import '../theme/app_theme.dart';
import '../widgets/shape_decorations.dart';
import '../widgets/transaction_tile.dart';

class AddEditTransactionView extends StatefulWidget {
  const AddEditTransactionView({
    super.key,
    required this.controller,
    this.initialTransaction,
    required this.onSaved,
    this.onCancel,
  });

  final ExpenseController controller;
  final TransactionItem? initialTransaction;
  final VoidCallback onSaved;
  final VoidCallback? onCancel;

  @override
  State<AddEditTransactionView> createState() => _AddEditTransactionViewState();
}

class _AddEditTransactionViewState extends State<AddEditTransactionView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _dateController;

  TransactionType _selectedType = TransactionType.expense;
  String _selectedCategory = 'Food & Beverage';
  DateTime _selectedDate = DateTime.now();

  final List<String> _expenseCategories = [
    'Food & Beverage',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Health',
    'Other',
  ];

  final List<String> _incomeCategories = [
    'Salary',
    'Freelance',
    'Business',
    'Investments',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.initialTransaction;
    _amountController = TextEditingController(
      text: item != null ? item.amount.toStringAsFixed(2) : '',
    );
    _descriptionController = TextEditingController(text: item?.description ?? '');
    _dateController = TextEditingController(
      text: DateFormat('MMM d, yyyy').format(item?.date ?? DateTime.now()),
    );

    if (item != null) {
      _selectedType = item.type;
      _selectedCategory = item.category;
      _selectedDate = item.date;
    } else {
      _selectedCategory = _expenseCategories.first;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('MMM d, yyyy').format(picked);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an amount greater than 0'),
          backgroundColor: AppColors.coralRed,
        ),
      );
      return;
    }

    final item = TransactionItem(
      id: widget.initialTransaction?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: _selectedType,
      amount: amount,
      category: _selectedCategory,
      description: _descriptionController.text.trim(),
      date: _selectedDate,
    );

    if (widget.initialTransaction != null) {
      await widget.controller.updateTransaction(item);
    } else {
      await widget.controller.addTransaction(item);
    }

    widget.onSaved();
  }

  Future<void> _deleteTransaction() async {
    final item = widget.initialTransaction;
    if (item == null) return;

    final confirmed = await showDeleteConfirmationDialog(
      context,
      description: item.description,
    );

    if (confirmed && mounted) {
      widget.controller.deleteTransaction(item.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted "${item.description}"'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      widget.onCancel?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialTransaction != null;
    final categories = _selectedType == TransactionType.expense ? _expenseCategories : _incomeCategories;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Blue Header
          BubbleHeader(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            isEditing ? 'Edit Transaction' : 'New Transaction',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                        if (isEditing)
                          IconButton(
                            onPressed: _deleteTransaction,
                            tooltip: 'Delete Transaction',
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                          ),
                        if (widget.onCancel != null)
                          IconButton(
                            onPressed: widget.onCancel,
                            icon: const Icon(Icons.close_rounded, color: Colors.white),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isEditing
                          ? 'Update the recorded financial details below'
                          : 'Log cash flow, expenses, or income in seconds',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Form Body
          Transform.translate(
            offset: const Offset(0, -14),
            child: CurvedSheetContainer(
              topRadius: 32,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Income / Expense Toggle
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedType = TransactionType.expense;
                                  _selectedCategory = _expenseCategories.first;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _selectedType == TransactionType.expense
                                      ? AppColors.primaryBlue
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: _selectedType == TransactionType.expense
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primaryBlue.withValues(alpha: 0.25),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Center(
                                  child: Text(
                                    'Expense',
                                    style: TextStyle(
                                      color: _selectedType == TransactionType.expense
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedType = TransactionType.income;
                                  _selectedCategory = _incomeCategories.first;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _selectedType == TransactionType.income
                                      ? AppColors.mintGreen
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: _selectedType == TransactionType.income
                                      ? [
                                          BoxShadow(
                                            color: AppColors.mintGreen.withValues(alpha: 0.25),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Center(
                                  child: Text(
                                    'Income',
                                    style: TextStyle(
                                      color: _selectedType == TransactionType.income
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Amount Field
                    const Text(
                      'Amount',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Container(
                          width: 58,
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'LKR',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryBlue,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        hintText: '0.00',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: AppColors.borderLight),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter an amount';
                        }
                        if (double.tryParse(value.trim()) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Category Selection Chips
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedCategory = cat),
                          selectedColor: AppColors.primaryBlue,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 12.5,
                          ),
                          backgroundColor: const Color(0xFFF1F5F9),
                          side: BorderSide(
                            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Weekly grocery shopping, Coffee...',
                        prefixIcon: const Icon(Icons.edit_note_rounded),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: AppColors.borderLight),
                        ),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Enter a description' : null,
                    ),
                    const SizedBox(height: 20),
                    // Date
                    const Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: _pickDate,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.calendar_today_rounded),
                        suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: AppColors.borderLight),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Save Button
                    FilledButton(
                      onPressed: _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: Text(
                        isEditing ? 'Update Transaction' : 'Save Transaction',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (isEditing) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _deleteTransaction,
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.coralRed,
                            size: 20,
                          ),
                          label: const Text(
                            'Delete Transaction',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.coralRed,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFCA5A5)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
