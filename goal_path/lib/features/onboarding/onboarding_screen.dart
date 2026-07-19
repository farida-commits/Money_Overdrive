import 'package:flutter/material.dart';
// import 'package:goal_path/features/home/checklist_screen.dart';
import 'onboarding_page.dart';
import 'rate_app_dialog.dart';
import '../home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}
  Future<void> _showRateIfNeeded() async {
  final prefs = await SharedPreferences.getInstance();
  final shown = prefs.getBool('rate_shown') ?? false;
  if (!shown) {
    await prefs.setBool('rate_shown', true);
    // rate dialog көрсөт
    RateAppDialog();
  }
}


class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    super.initState();
    _showRateIfNeeded();
  }

  void _goToNextPage() {
    if (_currentPage == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        onPageChanged: (index) => setState(() => _currentPage = index),
        children: [
          OnboardingPage(
            surfaceColor: _dialogShown
            ? Colors.white
            : Color(0xFFE5E5EA),
            illustration: Image.asset(
              'assets/images/onboarding_1.png',
              width: double.infinity,
              fit: BoxFit.contain,
            ),
            title: 'WELCOME!',
            description: 'Our app is already helping hundreds\nof users reach their financial goals',
            buttonLabel: 'Continue',
            onPressed: _goToNextPage,
          ),
          OnboardingPage(
            illustration: Image.asset(
              'assets/images/onboarding_2.png',
              width: double.infinity,
              fit: BoxFit.contain,
            ),
            title: 'TAKE A PHOTO AND SAVE',
            description: 'To avoid losing important purchases\n- just take a photo and save it',
            buttonLabel: 'Continue',
            onPressed: _goToNextPage,
          ),
          OnboardingPage(
            illustration: Image.asset(
              'assets/images/onboarding_3.png',
              width: double.infinity,
              fit: BoxFit.contain,
            ),
            title: 'ADD YOUR GOALS',
            description: 'Set financial goals and track your\nprogress',
            buttonLabel: 'Continue',
            onPressed: _goToNextPage,
          ),
          OnboardingPage(
            illustration: Image.asset(
              'assets/images/onboarding_4.png',
              width: double.infinity,
              fit: BoxFit.contain,
            ),
            title: 'PURCHASE ANALYTICS',
            description: 'Visualize your expenses and\ncategorize your expenditures',
            buttonLabel: 'Start',
            onPressed: _goToNextPage,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}