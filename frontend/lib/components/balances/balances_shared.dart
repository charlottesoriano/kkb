import 'package:KKB/const/colors.dart';
import 'package:KKB/models/user.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef SuggestedPayment = ({User from, User to, double amount});

final balanceCurrency = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

BoxDecoration balanceCardDecoration({double radius = 20}) {
  return BoxDecoration(
    color: KKBColors.lightSurface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: KKBColors.lightBorder),
  );
}

ButtonStyle balanceOutlinedButtonStyle() {
  return OutlinedButton.styleFrom(
    foregroundColor: KKBColors.lightTextPrimary,
    backgroundColor: KKBColors.lightSurface,
    side: const BorderSide(color: KKBColors.lightBorder),
    minimumSize: const Size(0, 36),
    padding: const EdgeInsets.symmetric(horizontal: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}

class BalanceSectionLabel extends StatelessWidget {
  const BalanceSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: KKBTextStyles.bodyMediumBold.copyWith(color: KKBColors.lightTextPrimary));
  }
}
