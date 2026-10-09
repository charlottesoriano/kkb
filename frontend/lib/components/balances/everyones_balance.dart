import 'package:KKB/components/global/member_avatar.dart';
import 'package:KKB/components/balances/balances_shared.dart';
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
            MemberAvatar(user: balance.user, colorIndex: MemberAvatar.colorIndexIn(group.members, balance.user.id)),
            Expanded(
              child: Text(
                isMe ? '${balance.user.firstName} (you)' : balance.user.firstName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: KKBTextStyles.bodyMediumSemiBold.copyWith(color: KKBColors.lightTextPrimary),
              ),
            ),
            Text(label, style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary)),
            Text('$sign${balanceCurrency.format(balance.amount.abs())}', style: KKBTextStyles.bodyMediumXBold.copyWith(color: color)),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: balanceCardDecoration(),
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
