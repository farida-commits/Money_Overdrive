import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1F27),
      ),
      child: Row(
        children: [
          _buildItem(0, 'assets/icons/ic_checklist.svg', 'Checklist'),
          _buildItem(1, 'assets/icons/ic_goals.svg', 'Goals'),
          _buildItem(2, 'assets/icons/ic_analytics.svg', 'Analytics'),
          _buildItem(3, 'assets/icons/ic_settings.svg', 'Settings'),
        ],
      ),
    );
  }

  Widget _buildItem(int index, String iconPath, String label) {
    final isActive = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                iconPath,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  isActive ? AppColors.textOnDark : AppColors.grey,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? AppColors.textOnDark : AppColors.grey,
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}