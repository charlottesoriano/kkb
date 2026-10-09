import 'package:KKB/const/colors.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// shared pieces used by the add expense screen and its sections

enum SplitType { equal, custom }

final expenseCurrency = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

// digits with at most 2 decimals, e.g. "3600" or "3600.50"
final expenseAmountFormatter = FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'));

BoxDecoration expenseCardDecoration({double radius = 20}) {
  return BoxDecoration(
    color: KKBColors.lightSurface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: KKBColors.lightBorder),
  );
}

class ExpenseSectionLabel extends StatelessWidget {
  const ExpenseSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: KKBTextStyles.bodySmallSemiBold.copyWith(color: KKBColors.lightTextPrimary));
  }
}
