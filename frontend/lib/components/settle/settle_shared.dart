import 'package:KKB/const/colors.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// shared pieces used by the settle screen and its sections

final settleCurrency = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

class SettleCard extends StatelessWidget {
  const SettleCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: KKBColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: KKBColors.lightBorder),
        boxShadow: [BoxShadow(color: KKBColors.lightTextPrimary.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }
}

class SettleButton extends StatelessWidget {
  const SettleButton({super.key, required this.label, required this.onPressed, this.filled = true, this.height = 48});

  final String label;
  final VoidCallback? onPressed;
  final bool filled;
  final double height;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    final size = Size.fromHeight(height);

    if (!filled) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: size,
          shape: shape,
          side: const BorderSide(color: KKBColors.lightBorder),
          foregroundColor: KKBColors.lightTextPrimary,
          textStyle: KKBTextStyles.buttonMedium,
        ),
        child: Text(label),
      );
    }

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(minimumSize: size, shape: shape, backgroundColor: KKBColors.lightPrimary, foregroundColor: KKBColors.lightOnPrimary, textStyle: KKBTextStyles.buttonLarge),
      child: Text(label),
    );
  }
}

class SettlePill extends StatelessWidget {
  const SettlePill({super.key, required this.label, required this.background, required this.foreground});

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: KKBTextStyles.labelSmallBold.copyWith(color: foreground)),
    );
  }
}
