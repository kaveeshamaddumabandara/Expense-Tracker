import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomBlueBottomBar extends StatelessWidget {
  const CustomBlueBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom + 4
            : 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomBarItem(
            icon: Icons.home_rounded,
            isSelected: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _BottomBarItem(
            icon: Icons.credit_card_rounded,
            isSelected: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _BottomBarItem(
            icon: Icons.add_circle_rounded,
            isSelected: currentIndex == 2,
            isCenterAction: true,
            onTap: () => onTap(2),
          ),
          _BottomBarItem(
            icon: Icons.receipt_long_rounded,
            isSelected: currentIndex == 3,
            onTap: () => onTap(3),
          ),
          _BottomBarItem(
            icon: Icons.person_outline_rounded,
            isSelected: currentIndex == 4,
            onTap: () => onTap(4),
          ),
        ],
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  const _BottomBarItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.isCenterAction = false,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isCenterAction;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.22)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: isCenterAction
            ? Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add,
                  color: AppColors.primaryBlue,
                  size: 26,
                ),
              )
            : Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.65),
                size: 24,
              ),
      ),
    );
  }
}
