import 'package:KKB/const/colors.dart';
import 'package:flutter/material.dart';

// white bordered card used across the app
class KKBCard extends StatelessWidget {
  const KKBCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.radius = 20, this.hasShadow = false, this.width});

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  // soft drop shadow, e.g. the settle screen cards
  final bool hasShadow;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: KKBColors.lightSurface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: KKBColors.lightBorder),
        boxShadow: hasShadow ? [BoxShadow(color: KKBColors.lightTextPrimary.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))] : null,
      ),
      child: child,
    );
  }
}
