import 'dart:async';

import 'package:flutter/material.dart';

import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo_tokende_old.png',
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 35),

            const Text(
              'Tokende',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A2A66),
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              'Réservez, achetez et voyagez en toute confiance.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFFFF6B00),
              ),
            ),
          ],
        ),
      ),
    );
  }
}