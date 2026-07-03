import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class OnboardingPage extends StatelessWidget {
  final Color surfaceColor;
  final Widget illustration;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onPressed;

  const OnboardingPage ({
    super.key,
    this.surfaceColor = Colors.white,
    required this.illustration,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: illustration,
            ),
            ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.onboardingTitle,
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.onboardingDescription,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(14),
                      ),
                      ),
                    onPressed: onPressed,
                    child: Text(buttonLabel, style: AppTextStyles.buttonText),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}