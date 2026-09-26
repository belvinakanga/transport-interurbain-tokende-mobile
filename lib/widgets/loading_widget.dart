import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final Color color;
  final double size;

  const LoadingWidget({
    super.key,
    this.message,
    this.color = const Color(0xFFFF6B00),
    this.size = 45,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),

          if (message != null) ...[
            const SizedBox(height: 18),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF555555),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}