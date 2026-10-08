import 'package:KKB/const/colors.dart';
import 'package:KKB/models/user.dart';
import 'package:KKB/utils/helper.dart';
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

class ExpenseMemberAvatar extends StatelessWidget {
  const ExpenseMemberAvatar({
    super.key,
    required this.member,
    required this.colorIndex,
    required this.size,
    this.selected = false,
  });

  static const _avatarColors = [
    (KKBColors.lightAvatar1, KKBColors.lightOnAvatar1),
    (KKBColors.lightAvatar2, KKBColors.lightOnAvatar2),
    (KKBColors.lightAvatar3, KKBColors.lightOnAvatar3),
    (KKBColors.lightAvatar4, KKBColors.lightOnAvatar4),
  ];

  final User member;
  // position in the group's member list, keeps each member's color the same across sections
  final int colorIndex;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final (avatarColor, onAvatarColor) = _avatarColors[colorIndex % _avatarColors.length];

    final circle = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: avatarColor, shape: BoxShape.circle),
      child: Text(
        Helper.initials('${member.firstName} ${member.lastName}'),
        style: (size >= 48 ? KKBTextStyles.bodyMediumXBold : KKBTextStyles.bodyXSmallBold)
            .copyWith(color: onAvatarColor),
      ),
    );

    if (!selected) return circle;

    // payer ring: avatar -> white gap -> primary ring
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: KKBColors.lightPrimary, width: 2),
      ),
      child: circle,
    );
  }
}
