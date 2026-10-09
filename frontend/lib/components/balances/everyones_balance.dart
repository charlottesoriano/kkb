import 'package:KKB/components/global/card.dart';
import 'package:KKB/utils/helper.dart';
import 'package:KKB/components/global/member_avatar.dart';
import 'package:KKB/components/global/member_display.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/models/balance.dart';
import 'package:KKB/models/group.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';

// card listing every member's balance in the group
class EveryonesBalance extends StatelessWidget {
  const EveryonesBalance({super.key, required this.group, required this.balances, required this.userId});

  final Group group;
  final List<Balance> balances;
  final String userId;

  @override
  Widget build(BuildContext context) {
    Widget balanceWidget(Balance balance) {
      final isMe = balance.user.id == userId;
      final (label, color, sign) = switch (balance.amount) {
        > 0 => ('gets back', KKBColors.lightOwed, '+'),
        < 0 => (isMe ? 'owe' : 'owes', KKBColors.lightOwe, '−'),
        _ => ('settled', KKBColors.lightTextSecondary, ''),
      };

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          spacing: 12,
          children: [
            Expanded(
              child: MemberDisplay(
                user: balance.user,
                isHorizontal: true,
                isMe: isMe,
                colorIndex: MemberAvatar.colorIndexIn(group.members, balance.user.id),
              ),
            ),
            Text(label, style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary)),
            Text('$sign${Helper.currency.format(balance.amount.abs())}', style: KKBTextStyles.bodyMediumXBold.copyWith(color: color)),
          ],
        ),
      );
    }
    
    return KKBCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          for (var i = 0; i < balances.length; i++) 
            ...[if (i > 0) const Divider(height: 1, color: KKBColors.lightBorder), 
          balanceWidget(balances[i])],
        ],
      ),
    );
  }
}
