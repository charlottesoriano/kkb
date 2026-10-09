import 'package:KKB/const/colors.dart';
import 'package:flutter/material.dart';

// circled "G" shown on the Google sign in / sign up buttons
class GoogleBadge extends StatelessWidget {
  const GoogleBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: KKBColors.lightTextPrimary, width: 1.2),
      ),
      child: const Text(
        'G',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: KKBColors.lightTextPrimary),
      ),
    );
  }
}
