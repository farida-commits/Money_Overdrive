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
        // backgroundColor: const Color(0xFF1A1F27), // конкреттүү түс бер
        // selectedItemColor: Colors.white,
        // unselectedItemColor: Colors.grey,
        // type: BottomNavigationBarType.fixed,
        // items: [
        //   BottomNavigationBarItem(
        //     icon: Icon(Icons.checklist_rounded),
        //     label: 'Cheklist',
        //   ),
        //   BottomNavigationBarItem(
        //     icon: Icon(Icons.track_changes),
        //     label: 'Goals',
        //   ),
        //   BottomNavigationBarItem(
        //     icon:  Icon(Icons.bar_chart),
        //     label: 'Analytics',
        //   ),
        //   BottomNavigationBarItem(
        //     icon: Icon(Icons.settings ),
        //     label: 'Settings',
        //   ),
        // ],
      ),
    );
  }
}
