import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ActivityItemData {
  const ActivityItemData({
    required this.title,
    required this.icon,
    this.iconColor = AppColors.primaryBlue,
    this.badgeColor,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final Color? badgeColor;
  final VoidCallback onTap;
}

class QuickActivitiesRow extends StatelessWidget {
  const QuickActivitiesRow({
    super.key,
    required this.items,
  });

  final List<ActivityItemData> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: _ActivityButton(item: item),
          ),
        );
      }).toList(),
    );
  }
}

class _ActivityButton extends StatefulWidget {
  const _ActivityButton({required this.item});

  final ActivityItemData item;

  @override
  State<_ActivityButton> createState() => _ActivityButtonState();
}

class _ActivityButtonState extends State<_ActivityButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.item.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.borderLight, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E3A8A).withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: (widget.item.badgeColor ?? widget.item.iconColor).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  widget.item.icon,
                  color: widget.item.iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
