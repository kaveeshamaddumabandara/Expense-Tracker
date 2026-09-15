import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models.dart';
import '../theme/app_theme.dart';

/// Displays a confirmation dialog before deleting a transaction.
///
/// Returns `true` if the user confirmed deletion, or `false` if cancelled.
/// Useful as a clear pattern for learning Flutter dialogs ([showDialog] + [AlertDialog]).
Future<bool> showDeleteConfirmationDialog(
  BuildContext context, {
  String? description,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        icon: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.coralRed.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.delete_forever_rounded,
            color: AppColors.coralRed,
            size: 24,
          ),
        ),
        title: const Text(
          'Delete Transaction',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Are you sure you want to delete this transaction?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                height: 1.35,
              ),
            ),
            if (description != null && description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'This will remove "$description" from your records.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.coralRed,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      );
    },
  );

  return result ?? false;
}

class AppTransactionTile extends StatelessWidget {
  const AppTransactionTile({
    super.key,
    required this.item,
    this.onTap,
    this.onDelete,
  });

  final TransactionItem item;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'food & beverage':
        return Icons.restaurant_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'bills':
        return Icons.receipt_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      case 'health':
        return Icons.medical_services_rounded;
      case 'salary':
        return Icons.account_balance_wallet_rounded;
      case 'freelance':
      case 'business':
        return Icons.work_rounded;
      default:
        return Icons.payments_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = item.type == TransactionType.income;
    final amountSign = isIncome ? '+' : '-';
    final amountColor = isIncome ? AppColors.mintGreen : AppColors.textDark;

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        if (onDelete == null) return false;
        return await showDeleteConfirmationDialog(
          context,
          description: item.description,
        );
      },
      onDismissed: (_) {
        onDelete?.call();
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.coralRed,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight, width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E3A8A).withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Circular icon container matching reference design
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isIncome
                      ? AppColors.mintGreenLight
                      : const Color(0xFF2662EA).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getCategoryIcon(item.category),
                  size: 22,
                  color: isIncome ? AppColors.mintGreen : AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 14),
              // Description and Category/Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${item.category} • ${DateFormat('MMM d').format(item.date)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Amount and sign
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$amountSign LKR ${item.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: amountColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMM yyyy').format(item.date),
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              // Delete icon button for direct tap-to-delete with confirmation
              if (onDelete != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 19,
                    color: AppColors.textMuted,
                  ),
                  tooltip: 'Delete transaction',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  splashRadius: 18,
                  onPressed: () async {
                    final confirmed = await showDeleteConfirmationDialog(
                      context,
                      description: item.description,
                    );
                    if (confirmed) {
                      onDelete?.call();
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
