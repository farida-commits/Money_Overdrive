import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:goal_path/core/widgets/app_bottom_nav_bar.dart';
import 'package:goal_path/features/analytics/analytics_screen.dart';
import 'package:goal_path/features/goals/goals_screen.dart';
import 'package:goal_path/features/home/checklist_screen.dart';
import 'package:goal_path/features/settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIdex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        ChecklistScreen(),
        GoalsScreen(),
        AnalyticsScreen(),
        SettingsScreen(),
      ][currentIdex],
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: currentIdex,
        onTap: (value) {
          setState(() {
            currentIdex = value;
          });
        },
      ),
    );
  }
}
