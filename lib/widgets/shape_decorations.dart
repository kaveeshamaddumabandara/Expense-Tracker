import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Custom painter to draw organic translucent circular bubble patterns
/// matching the exact visual motif of the reference app.
class BubblePatternPainter extends CustomPainter {
  BubblePatternPainter({
    this.bubbleColor = Colors.white,
    this.baseOpacity = 0.12,
  });

  final Color bubbleColor;
  final double baseOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = bubbleColor.withValues(alpha: baseOpacity)
      ..style = PaintingStyle.fill;

    // Top-right large circle
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.15),
      size.width * 0.42,
      paint,
    );

    // Overlapping smaller circle
    final paint2 = Paint()
      ..color = bubbleColor.withValues(alpha: baseOpacity * 0.7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.95, size.height * 0.5),
      size.width * 0.35,
      paint2,
    );

    // Mid-left subtle circle
    final paint3 = Paint()
      ..color = bubbleColor.withValues(alpha: baseOpacity * 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.75),
      size.width * 0.3,
      paint3,
    );

    // Subtle bottom-right circle
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.95),
      size.width * 0.25,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant BubblePatternPainter oldDelegate) {
    return oldDelegate.bubbleColor != bubbleColor || oldDelegate.baseOpacity != baseOpacity;
  }
}

/// A blue header container that renders the organic circular bubbles
class BubbleHeader extends StatelessWidget {
  const BubbleHeader({
    super.key,
    required this.child,
    this.height,
    this.gradient,
  });

  final Widget child;
  final double? height;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: gradient ?? AppGradients.royalBlue,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: BubblePatternPainter(
                bubbleColor: Colors.white,
                baseOpacity: 0.14,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Curved white container that wraps sheet content overlapping the blue header
class CurvedSheetContainer extends StatelessWidget {
  const CurvedSheetContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 24, 20, 20),
    this.topRadius = 32.0,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double topRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(topRadius),
          topRight: Radius.circular(topRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}

/// Filter / Category Pill matching Screen 3 (Assets / Debt / Income)
class FilterPill extends StatelessWidget {
  const FilterPill({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.inactivePillBorder,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.24),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
