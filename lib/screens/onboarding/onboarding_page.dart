import 'package:flutter/material.dart';
import 'onboarding_model.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingModel data;

  const OnboardingPage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Image.asset(
            data.image,
            height: 280,
          ),

          const SizedBox(height: 40),

          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A2A66),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            data.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              color: Colors.black54,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}