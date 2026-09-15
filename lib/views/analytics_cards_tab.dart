import 'package:flutter/material.dart';
import '../controller.dart';
import '../models.dart';
import '../theme/app_theme.dart';
import '../widgets/circular_balance_hero.dart';
import '../widgets/shape_decorations.dart';
import '../widgets/tip_banner.dart';
import '../widgets/trend_chart.dart';
import '../widgets/virtual_card.dart';
import 'add_card_dialog.dart';

class AnalyticsCardsTab extends StatefulWidget {
  const AnalyticsCardsTab({
    super.key,
    required this.controller,
    required this.onAddTransaction,
  });

  final ExpenseController controller;
  final VoidCallback onAddTransaction;

  @override
  State<AnalyticsCardsTab> createState() => _AnalyticsCardsTabState();
}

class _AnalyticsCardsTabState extends State<AnalyticsCardsTab> {
  String _activePill = 'Assets'; // Assets, Debt, Income

  Future<void> _openAddCardDialog(BuildContext context) async {
    await showAddCardDialog(
      context,
      onCardAdded: (newCard) async {
        await widget.controller.addCard(newCard);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Card "${newCard.title}" added to wallet.'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  Future<void> _handleDeleteCard(BuildContext context, VirtualCardData card) async {
    final confirmed = await showDeleteCardDialog(context, card);
    if (confirmed == true && context.mounted) {
      await widget.controller.deleteCard(card.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Card "${card.title}" deleted.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.controller.getSummary();
    final userName = widget.controller.userName;
    final cards = widget.controller.cards;

    // Calculate weekly trend spots based on actual transactions
    final weeklyAmounts = <double>[0, 0, 0, 0, 0, 0, 0];
    final now = DateTime.now();
    for (final item in widget.controller.transactions) {
      final diff = now.difference(item.date).inDays;
      if (diff >= 0 && diff < 7) {
        final weekdayIndex = item.date.weekday % 7; // Sunday = 0
        if (_activePill == 'Income' && item.type == TransactionType.income) {
          weeklyAmounts[weekdayIndex] += item.amount;
        } else if (_activePill == 'Debt' && item.type == TransactionType.expense) {
          weeklyAmounts[weekdayIndex] += item.amount;
        } else if (_activePill == 'Assets') {
          weeklyAmounts[weekdayIndex] += item.amount;
        }
      }
    }

    final hasWeeklyData = weeklyAmounts.any((a) => a > 0);
    final chartData = hasWeeklyData
        ? weeklyAmounts
        : [120.0, 95.0, 174.0, 110.0, 240.0, 451.0, 310.0];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Blue Curved Header with Shireen Avatar & Circular Balance Hero matching Screen 3
          BubbleHeader(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 36),
                child: Column(
                  children: [
                    // Avatar & Menu row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFC7D2FE),
                                ),
                                child: Center(
                                  child: Text(
                                    userName.isNotEmpty ? userName[0].toUpperCase() : 'S',
                                    style: const TextStyle(
                                      color: AppColors.primaryBlue,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  userName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.menu_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Circular Hero Total Balance ($214,417 style from Screen 3)
                    CircularBalanceHero(
                      balance: summary.balance != 0 ? summary.balance : 214417.0,
                      title: 'Total Balance',
                      subtitle: summary.balance >= 0 ? 'On Track' : 'Over Budget',
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Curved White Sheet matching Screen 3
          Transform.translate(
            offset: const Offset(0, -18),
            child: CurvedSheetContainer(
              topRadius: 32,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter Pills: Assets | Debt | Income
                  Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FilterPill(
                            label: 'Assets',
                            isSelected: _activePill == 'Assets',
                            onTap: () => setState(() => _activePill = 'Assets'),
                          ),
                          const SizedBox(width: 8),
                          FilterPill(
                            label: 'Debt',
                            isSelected: _activePill == 'Debt',
                            onTap: () => setState(() => _activePill = 'Debt'),
                          ),
                          const SizedBox(width: 8),
                          FilterPill(
                            label: 'Income',
                            isSelected: _activePill == 'Income',
                            onTap: () => setState(() => _activePill = 'Income'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  // Dotted Spline Trend Chart with $174 and $451 peak markers
                  FinanceTrendChart(
                    weeklyAmounts: chartData,
                    primaryDottedColor: AppColors.primaryBlue,
                    secondaryDottedColor: const Color(0xFF93C5FD),
                  ),
                  const SizedBox(height: 28),
                  // "My Cards (4)" Section matching Screen 2
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Cards (${cards.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Add Card',
                        onPressed: () => _openAddCardDialog(context),
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Virtual Cards Carousel
                  VirtualCardsCarousel(
                    cards: cards,
                    onAddCard: () => _openAddCardDialog(context),
                    onDeleteCard: (card) => _handleDeleteCard(context, card),
                  ),
                  const SizedBox(height: 26),
                  // "Spending" reminder banner matching Screen 3
                  TipBannerCard(
                    title: 'Spending.',
                    subtitle: 'You forgot to add debit card number at payment #1323. Add it now.',
                    actionLabel: 'ADD CARD',
                    backgroundColor: const Color(0xFFDBEAFE),
                    iconData: Icons.credit_card_rounded,
                    iconColor: AppColors.primaryBlue,
                    onAction: () => _openAddCardDialog(context),
                    onDismiss: () {},
                  ),
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
