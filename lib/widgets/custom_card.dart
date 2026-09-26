import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color color;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color = Colors.white,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      width: double.infinity,
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}