import 'package:KKB/components/global/member_avatar.dart';
import 'package:KKB/components/balances/balances_shared.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/core/router.dart';
import 'package:KKB/models/group.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// one "X pays Y" row, with settle up if it's the current user's payment, remind otherwise
class SuggestedPaymentCard extends StatelessWidget {
  const SuggestedPaymentCard({super.key, required this.group, required this.payment, required this.userId});

  final Group group;
  final SuggestedPayment payment;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final isMine = payment.from.id == userId;
    final title = isMine ? 'You pay ${payment.to.firstName}' : '${payment.from.firstName} pays ${payment.to.firstName}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: balanceCardDecoration(),
      child: Row(
        spacing: 10,
        children: [
          // from -> to
          Row(
            spacing: 4,
            children: [
              MemberAvatar(user: payment.from, colorIndex: MemberAvatar.colorIndexIn(group.members, payment.from.id)),
              const Icon(Icons.arrow_forward_rounded, size: 14, color: KKBColors.lightTextSecondary),
              MemberAvatar(user: payment.to, colorIndex: MemberAvatar.colorIndexIn(group.members, payment.to.id)),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: KKBTextStyles.bodySmallBold.copyWith(color: KKBColors.lightTextPrimary),
                ),
                Text(isMine ? 'Pay to settle your balance' : 'Suggested payment', style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 6,
            children: [
              Text(balanceCurrency.format(payment.amount), style: KKBTextStyles.bodyMediumXBold.copyWith(color: isMine ? KKBColors.lightOwe : KKBColors.lightTextPrimary)),
              if (isMine)
                FilledButton(
                  onPressed: () => context.go(AppRoutes.groupSettle),
                  style: FilledButton.styleFrom(
                    backgroundColor: KKBColors.lightPrimary,
                    foregroundColor: KKBColors.lightOnPrimary,
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Settle up', style: KKBTextStyles.buttonSmall),
                )
              else
                OutlinedButton(
                  // TODO: send a reminder notification
                  onPressed: () {},
                  style: balanceOutlinedButtonStyle(),
                  child: Text('Remind', style: KKBTextStyles.buttonSmall),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
