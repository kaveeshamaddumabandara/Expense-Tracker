import 'package:flutter/material.dart';
import '../controller.dart';
import '../models.dart';
import '../theme/app_theme.dart';
import '../widgets/shape_decorations.dart';
import '../widgets/transaction_tile.dart';

class TransactionsTab extends StatefulWidget {
  const TransactionsTab({
    super.key,
    required this.controller,
    required this.onEditTransaction,
    required this.onAddTransaction,
  });

  final ExpenseController controller;
  final ValueChanged<TransactionItem> onEditTransaction;
  final VoidCallback onAddTransaction;

  @override
  State<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<TransactionsTab> {
  String _searchQuery = '';
  String _selectedType = 'All'; // All, Income, Expense
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Food & Beverage',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Health',
    'Salary',
    'Freelance',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = widget.controller.filteredTransactions(
      type: _selectedType == 'All' ? null : _selectedType,
      category: _selectedCategory == 'All' ? null : _selectedCategory,
      search: _searchQuery,
    );

    final summary = widget.controller.getSummary();

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
                        const Expanded(
                          child: Text(
                            'Transactions',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: widget.onAddTransaction,
                          icon: const Icon(
                            Icons.add_circle_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${filtered.length} entries recorded • Net balance LKR ${summary.balance.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Curved Content Sheet
          Transform.translate(
            offset: const Offset(0, -14),
            child: CurvedSheetContainer(
              topRadius: 32,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search transactions or merchant...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Type filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        FilterPill(
                          label: 'All Types',
                          isSelected: _selectedType == 'All',
                          onTap: () => setState(() => _selectedType = 'All'),
                        ),
                        const SizedBox(width: 8),
                        FilterPill(
                          label: 'Income',
                          isSelected: _selectedType == 'Income',
                          onTap: () => setState(() => _selectedType = 'Income'),
                          icon: Icons.arrow_downward_rounded,
                        ),
                        const SizedBox(width: 8),
                        FilterPill(
                          label: 'Expense',
                          isSelected: _selectedType == 'Expense',
                          onTap: () => setState(() => _selectedType = 'Expense'),
                          icon: Icons.arrow_upward_rounded,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Category chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (_) => setState(() => _selectedCategory = cat),
                            selectedColor: AppColors.primaryBlue.withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 12,
                            ),
                            side: BorderSide(
                              color: isSelected ? AppColors.primaryBlue : AppColors.borderLight,
                            ),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Transactions List
                  if (filtered.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 52,
                            color: AppColors.textMuted.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No matching transactions found',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Try changing your search or filter options',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...filtered.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppTransactionTile(
                          item: item,
                          onTap: () => widget.onEditTransaction(item),
                          onDelete: () => widget.controller.deleteTransaction(item.id),
                        ),
                      );
                    }),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
