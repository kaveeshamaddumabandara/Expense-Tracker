import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TipBannerCard extends StatelessWidget {
  const TipBannerCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.actionLabel = 'LEARN MORE',
    this.onAction,
    this.onDismiss,
    this.backgroundColor = const Color(0xFFD8F3E5),
    this.iconData = Icons.savings_rounded,
    this.iconColor = const Color(0xFF10B981),
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;
  final Color backgroundColor;
  final IconData iconData;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppShadows.softCard,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Left graphic block
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Icon(
                        iconData,
                        size: 40,
                        color: iconColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Middle texts and action button
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: onAction,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              actionLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Close button top-right
            if (onDismiss != null)
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: onDismiss,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 15,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
