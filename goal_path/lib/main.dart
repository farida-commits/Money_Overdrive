import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'package:goal_path/core/models/goal_model.dart';
import 'features/home/home_screen.dart';
import 'features/splash/splash_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:goal_path/core/providers/purchases_provider.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(GoalModelAdapter());

  await Hive.openBox('purchases'); 
  await Hive.openBox('settings'); 
  await Hive.openBox<GoalModel>('goals_box');

  runApp(
    ChangeNotifierProvider(
      create: (_) => PurchasesProvider(),
      child: GoalPathApp()
    ),
  );
}

class GoalPathApp extends StatelessWidget {
  const GoalPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Goal Path',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
      ],
      themeMode: ThemeMode.system,
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
        final settingsBox = Hive.box('settings');
        final onboardingShown = settingsBox.get('onboarding_shown', defaultValue: false);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => onboardingShown
          ? const HomeScreen()
          : const OnboardingScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => const SplashScreen();
}

  