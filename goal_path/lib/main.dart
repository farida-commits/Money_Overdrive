import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

void main() {
  runApp(const GoalPathApp());
}

class GoalPathApp extends StatelessWidget {
  const GoalPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Goal Path',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const _SplashGate(),
    );
  }
}

// Показывает сплэш ~1.5 сек, потом переключает на онбординг
class _SplashGate extends StatefulWidget {
  const _SplashGate();

  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) => const SplashScreen();
}