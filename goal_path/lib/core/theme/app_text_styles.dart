import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle onboardingTitle = TextStyle(
     fontFamily: 'SF Pro Display',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Color(0xFF333333),
    letterSpacing: 24 * 0.02,
    height: 1.0,
  );

  static const TextStyle onboardingDescription = TextStyle(
    fontFamily: 'SF Pro Display',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Color(0xFF333333),
    letterSpacing: 20 * 0.02,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: 'SF Pro Display',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnDark,
  );
}
