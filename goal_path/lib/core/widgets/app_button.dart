import 'package:flutter/material.dart';
import 'package:goal_path/core/theme/app_colors.dart';
import 'package:goal_path/core/constants/app_sizes.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // null = кнопка задизейблена (серая)

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // isEnabled — если onPressed передан, кнопка активна (синяя), иначе серая
    final isEnabled = onPressed != null;

    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          // Активная — primary синий, тогда запольненная — серый "кнопка +Add"
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: Color(0xffBBBBBB),
          foregroundColor: AppColors.textOnDark,
          disabledForegroundColor: Color(0xffBBBBBB),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: AppSizes.fontButton,
            fontWeight: FontWeight.w600,
            color: AppColors.textOnDark,
          ),
        ),
      ),
    );
  }
}