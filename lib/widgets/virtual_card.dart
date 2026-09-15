import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'shape_decorations.dart';

class VirtualCardData {
  VirtualCardData({
    String? id,
    required this.title,
    required this.cardNumber,
    required this.balance,
    required this.brand,
    this.gradientIndex = 0,
    Gradient? gradient,
    Color? textColor,
    Color? chipColor,
  })  : id = id ?? 'card_${DateTime.now().microsecondsSinceEpoch}',
        _customGradient = gradient,
        _customTextColor = textColor,
        _customChipColor = chipColor;

  final String id;
  final String title;
  final String cardNumber;
  final double balance;
  final String brand; // 'mastercard' or 'visa'
  final int gradientIndex;
  final Gradient? _customGradient;
  final Color? _customTextColor;
  final Color? _customChipColor;

  static const List<Gradient> presets = [
    AppGradients.cardDeepBlue,
    AppGradients.cardSoftBlue,
    LinearGradient(
      colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF065F46), Color(0xFF047857)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF4C1D95), Color(0xFF6D28D9)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];

  static const List<String> presetNames = [
    'Cobalt Blue',
    'Sky Blue',
    'Midnight Slate',
    'Emerald Green',
    'Deep Violet',
  ];

  Gradient get gradient =>
      _customGradient ?? presets[gradientIndex.clamp(0, presets.length - 1)];
  Color get textColor => _customTextColor ?? Colors.white;
  Color get chipColor =>
      _customChipColor ??
      (gradientIndex == 1
          ? const Color(0xFFFDE68A)
          : const Color(0xFFFFD54F));

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'cardNumber': cardNumber,
        'balance': balance,
        'brand': brand,
        'gradientIndex': gradientIndex,
      };

  factory VirtualCardData.fromJson(Map<String, dynamic> json) {
    return VirtualCardData(
      id: json['id'] as String,
      title: json['title'] as String,
      cardNumber: json['cardNumber'] as String,
      balance: (json['balance'] as num).toDouble(),
      brand: json['brand'] as String,
      gradientIndex: (json['gradientIndex'] as int?) ?? 0,
    );
  }
}

/// Confirmation dialog for deleting a virtual card.
Future<bool> showDeleteCardDialog(
  BuildContext context,
  VirtualCardData card,
) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      icon: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.coralRed.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.credit_card_off_rounded,
          color: AppColors.coralRed,
          size: 24,
        ),
      ),
      title: const Text(
        'Delete Card',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textDark,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Are you sure you want to delete this card?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${card.title} (•••• ${card.cardNumber}) will be removed from your wallet.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.coralRed,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
    ),
  );

  return result ?? false;
}

class VirtualCardWidget extends StatelessWidget {
  const VirtualCardWidget({
    super.key,
    required this.card,
    this.width = 240,
    this.height = 310,
    this.onTap,
    this.onDelete,
  });

  final VirtualCardData card;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: card.gradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Bubble overlay pattern
              Positioned.fill(
                child: CustomPaint(
                  painter: BubblePatternPainter(
                    bubbleColor: Colors.white,
                    baseOpacity: 0.14,
                  ),
                ),
              ),
              // Card Details
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: Chip and masked card number + Delete button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Chip
                        Container(
                          width: 34,
                          height: 24,
                          decoration: BoxDecoration(
                            color: card.chipColor,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 20,
                              height: 13,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  width: 0.8,
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                        // Masked number & delete button
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '•••• ${card.cardNumber}',
                                    style: TextStyle(
                                      color: card.textColor.withValues(alpha: 0.85),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.0,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              if (onDelete != null) ...[
                                const SizedBox(width: 2),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline_rounded,
                                    color: card.textColor.withValues(alpha: 0.85),
                                    size: 18,
                                  ),
                                  tooltip: 'Delete Card',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 26,
                                    minHeight: 26,
                                  ),
                                  splashRadius: 14,
                                  onPressed: onDelete,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Middle: Balance
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            card.title.toUpperCase(),
                            style: TextStyle(
                              color: card.textColor.withValues(alpha: 0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'LKR ${card.balance.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: card.textColor,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Bottom: Brand logo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (card.brand.toLowerCase() == 'mastercard')
                          // Mastercard overlapping circles logo
                          SizedBox(
                            width: 44,
                            height: 26,
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 0,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEB001B),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 14,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF79E1B).withValues(alpha: 0.88),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          // VISA text logo
                          Text(
                            'VISA',
                            style: TextStyle(
                              color: card.textColor,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        Icon(
                          Icons.contactless_rounded,
                          color: card.textColor.withValues(alpha: 0.75),
                          size: 24,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VirtualCardsCarousel extends StatefulWidget {
  const VirtualCardsCarousel({
    super.key,
    required this.cards,
    this.onDeleteCard,
    this.onAddCard,
  });

  final List<VirtualCardData> cards;
  final ValueChanged<VirtualCardData>? onDeleteCard;
  final VoidCallback? onAddCard;

  @override
  State<VirtualCardsCarousel> createState() => _VirtualCardsCarouselState();
}

class _VirtualCardsCarouselState extends State<VirtualCardsCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.72);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return Container(
        height: 220,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.credit_card_off_rounded,
                size: 48,
                color: AppColors.textMuted.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 10),
              const Text(
                'No cards in wallet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Add your credit or debit card to track balances',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              if (widget.onAddCard != null) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: widget.onAddCard,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Card'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.cards.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              final card = widget.cards[index];
              return AnimatedScale(
                scale: _currentIndex == index ? 1.0 : 0.92,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: VirtualCardWidget(
                    card: card,
                    onDelete: widget.onDeleteCard != null
                        ? () => widget.onDeleteCard!(card)
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.cards.length, (index) {
            final isCurrent = index == _currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isCurrent ? 22 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: isCurrent ? AppColors.primaryBlue : AppColors.inactivePillBorder,
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
      ],
    );
  }
}
