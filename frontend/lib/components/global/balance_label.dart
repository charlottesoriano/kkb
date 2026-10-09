import 'package:KKB/utils/helper.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';

class BalanceLabel extends StatelessWidget {
  const BalanceLabel({super.key, required this.balance, this.crossAxisAlignment = CrossAxisAlignment.end, this.labelStyle = KKBTextStyles.bodyXSmall, this.amountStyle = KKBTextStyles.bodyLargeXBold});

  // positive = you're owed, negative = you owe
  final double balance;
  final CrossAxisAlignment crossAxisAlignment;
  // base styles; colors are applied on top
  final TextStyle labelStyle;
  final TextStyle amountStyle;


  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (balance) {
      > 0 => ("You're owed", KKBColors.lightOwed),
      < 0 => ('You owe', KKBColors.lightOwe),
      _ => ('All settled up', KKBColors.lightTextSecondary),
    };

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(label, style: labelStyle.copyWith(color: KKBColors.lightTextSecondary)),
        // shrink large amounts instead of overflowing narrow cards
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: crossAxisAlignment == CrossAxisAlignment.start ? Alignment.centerLeft : Alignment.centerRight,
          child: Text(Helper.currency.format(balance.abs()), style: amountStyle.copyWith(color: color)),
        ),
      ],
    );
  }
}
