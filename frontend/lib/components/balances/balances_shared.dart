import 'package:KKB/const/colors.dart';
import 'package:KKB/models/group.dart';
import 'package:KKB/models/user.dart';
import 'package:KKB/utils/helper.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// shared pieces used by the balances screen and its sections

// one "X pays Y" suggestion from the simplified debts
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

class BalanceMemberAvatar extends StatelessWidget {
  const BalanceMemberAvatar({super.key, required this.group, required this.member, this.size = 32});

  static const _avatarColors = [
    (KKBColors.lightAvatar1, KKBColors.lightOnAvatar1),
    (KKBColors.lightAvatar2, KKBColors.lightOnAvatar2),
    (KKBColors.lightAvatar3, KKBColors.lightOnAvatar3),
    (KKBColors.lightAvatar4, KKBColors.lightOnAvatar4),
  ];

  // the member's position in the group keeps their color the same across sections
  final Group group;
  final User member;
  final double size;

  @override
  Widget build(BuildContext context) {
    final index = group.members.indexWhere((m) => m.id == member.id);
    final (avatarColor, onAvatarColor) = _avatarColors[(index < 0 ? 0 : index) % _avatarColors.length];

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: avatarColor, shape: BoxShape.circle),
      child: Text(
        Helper.initials('${member.firstName} ${member.lastName}'),
        style: KKBTextStyles.bodyXSmallBold.copyWith(color: onAvatarColor),
      ),
    );
  }
}
