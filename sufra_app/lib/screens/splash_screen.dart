import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../theme/colors.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _decideNext();
  }

  Future<void> _decideNext() async {
    await Future.delayed(const Duration(milliseconds: 900));
    final onboarded = await StorageService().isOnboarded();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => onboarded ? const HomeScreen() : const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SufraColors.pageBackground(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                'assets/icon/app_icon.png',
                width: 120,
                height: 120,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'سُفرة',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: SufraColors.text(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'وجبات أسرتك، بثقة',
              style: TextStyle(fontSize: 15, color: SufraColors.muted(context)),
            ),
          ],
        ),
      ),
    );
  }
}
