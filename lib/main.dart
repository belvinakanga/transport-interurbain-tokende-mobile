import 'package:flutter/material.dart';

import 'screens/splash/splash_screen.dart';

void main() {
  runApp(const TokendeApp());
}

class TokendeApp extends StatelessWidget {
  const TokendeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tokende',

      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor:
        const Color(0xFFF8F9FB),

        colorScheme:
        ColorScheme.fromSeed(
          seedColor:
          const Color(0xFF0A2A66),
        ),
      ),

      home: const SplashScreen(),
    );
  }
}