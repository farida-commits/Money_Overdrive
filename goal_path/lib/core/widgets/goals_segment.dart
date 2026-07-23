import 'package:flutter/material.dart';
import 'package:goal_path/core/theme/app_colors.dart';

class GoalsSegment extends StatelessWidget {
  final bool isActiveSelected;
  final ValueChanged<bool> onSegmentChanged;

  const GoalsSegment({
    super.key,
    required this.isActiveSelected,
    required this.onSegmentChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0x33FFFFFF),
          width: 1.5,
        )
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onSegmentChanged(true),
              child: Container(
                decoration: BoxDecoration(
                  color: isActiveSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center, 
                child: Text(
                  'Active',
                  style: TextStyle(
                    color: isActiveSelected ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onSegmentChanged(false),
              child: Container(
                decoration: BoxDecoration(
                  color: !isActiveSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center, 
                child: Text(
                  'Completed',
                  style: TextStyle(
                    color: !isActiveSelected ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}