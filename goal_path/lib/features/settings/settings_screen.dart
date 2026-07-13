import 'package:flutter/material.dart';
import 'package:goal_path/core/constants/app_sizes.dart';
import 'package:goal_path/core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // ДОБАВИЛИ: settings пункттары
  static const _items = [
    'Privacy Policy',
    'Terms of Use',
    'Support',
    'Share',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: AppSizes.fontAppar,
            fontWeight: FontWeight.w500,
            color: AppColors.textOnDark,
            letterSpacing: 14 * 0.02,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: _items.map((title) => _buildItem(title)).toList(),
        ),
      ),
    );
  }

  Widget _buildItem(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: () {
          // TODO: навигация — Privacy Policy, Terms of Use, Support, Share
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0x334132C7), // карточка түсү
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: AppSizes.fontButton,
              fontWeight: FontWeight.w500,
              color: AppColors.textOnDark,
              letterSpacing: 14 * 0.02,
            ),
          ),
        ),
      ),
    );
  }
}