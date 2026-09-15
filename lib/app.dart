import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controller.dart';
import 'models.dart';
import 'theme/app_theme.dart';
import 'views/add_edit_transaction_dialog.dart';
import 'views/analytics_cards_tab.dart';
import 'views/app_lock_screen.dart';
import 'views/dashboard_tab.dart';
import 'views/profile_tab.dart';
import 'views/transactions_tab.dart';
import 'widgets/custom_bottom_bar.dart';

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExpenseController(),
      child: MaterialApp(
        title: 'Smart Finance',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const ExpenseTrackerHome(),
      ),
    );
  }
}

class ExpenseTrackerHome extends StatelessWidget {
  const ExpenseTrackerHome({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ExpenseController>();

    if (controller.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.primaryBlue,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/extrack_logo.png',
                  height: 64,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Smart Finance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 14),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Offline app lock check
    if (controller.isLocked) {
      return const AppLockScreen();
    }

    return HomeScreen(controller: controller);
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.controller});

  final ExpenseController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  TransactionItem? _editingTransaction;

  void _onEditTransaction(TransactionItem item) {
    setState(() {
      _editingTransaction = item;
      _currentIndex = 2; // Jump to Add/Edit tab
    });
  }

  void _onResetEditing() {
    setState(() {
      _editingTransaction = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      // Tab 0: Dashboard (Screen 1 from reference)
      DashboardTab(
        controller: widget.controller,
        onNavigateToTransactions: () => setState(() => _currentIndex = 3),
        onNavigateToAdd: () {
          _onResetEditing();
          setState(() => _currentIndex = 2);
        },
        onNavigateToCards: () => setState(() => _currentIndex = 1),
        onEditTransaction: _onEditTransaction,
      ),
      // Tab 1: Cards & Analytics (Screen 2 & 3 from reference)
      AnalyticsCardsTab(
        controller: widget.controller,
        onAddTransaction: () {
          _onResetEditing();
          setState(() => _currentIndex = 2);
        },
      ),
      // Tab 2: Add / Edit Transaction
      AddEditTransactionView(
        controller: widget.controller,
        initialTransaction: _editingTransaction,
        onSaved: () {
          _onResetEditing();
          setState(() => _currentIndex = 0);
        },
        onCancel: () {
          _onResetEditing();
          setState(() => _currentIndex = 0);
        },
      ),
      // Tab 3: Transactions history & search
      TransactionsTab(
        controller: widget.controller,
        onEditTransaction: _onEditTransaction,
        onAddTransaction: () {
          _onResetEditing();
          setState(() => _currentIndex = 2);
        },
      ),
      // Tab 4: Profile & Security Settings
      ProfileTab(
        controller: widget.controller,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: CustomBlueBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != 2 && _editingTransaction != null) {
            _onResetEditing();
          }
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
