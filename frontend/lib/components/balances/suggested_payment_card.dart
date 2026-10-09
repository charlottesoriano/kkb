import 'package:KKB/components/global/member_avatar.dart';
import 'package:KKB/components/balances/balances_shared.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/core/router.dart';
import 'package:KKB/models/group.dart';
import 'package:KKB/providers/groups/group_settlements.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:KKB/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// one "X pays Y" row, with settle up if it's the current user's payment, remind if it's owed to them
class SuggestedPaymentCard extends ConsumerStatefulWidget {
  const SuggestedPaymentCard({super.key, required this.group, required this.payment, required this.userId});

  final Group group;
  final SuggestedPayment payment;
  final String userId;

  @override
  ConsumerState<SuggestedPaymentCard> createState() => _SuggestedPaymentCardState();
}

class _SuggestedPaymentCardState extends ConsumerState<SuggestedPaymentCard> {
  // blocks repeat taps while the reminder is being sent
  bool _sending = false;

  Future<void> _remind() async {
    setState(() => _sending = true);
    final result = await ref.read(groupSettlementsProvider(widget.group.id).notifier).sendReminder(widget.payment.from, widget.payment.amount);
    if (!mounted) return;
    setState(() => _sending = false);
    if (!result.status) return Helper.showErrorSnackBar(context, result.message, action: DbAction.insert);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message ?? 'Reminder sent'),
        backgroundColor: KKBColors.lightTextSuccess,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final payment = widget.payment;
    final group = widget.group;
    final isMine = payment.from.id == widget.userId;
    // only the person being paid can remind the payer
    final isOwedToMe = payment.to.id == widget.userId;
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
              else if (isOwedToMe)
                OutlinedButton(
                  onPressed: _sending ? null : _remind,
                  style: balanceOutlinedButtonStyle(),
                  child: Text(_sending ? 'Sending…' : 'Remind', style: KKBTextStyles.buttonSmall),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
