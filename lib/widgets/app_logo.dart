import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({
    super.key,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'tokende_logo',
      child: Image.asset(
        'assets/images/logo_tokende_old.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}