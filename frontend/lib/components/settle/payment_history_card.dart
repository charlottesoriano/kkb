import 'package:KKB/components/global/empty_state.dart';
import 'package:KKB/components/settle/settle_shared.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/models/settlement.dart';
import 'package:KKB/models/user.dart';
import 'package:KKB/providers/auth/current_user.dart';
import 'package:KKB/providers/groups/group_settlements.dart';
import 'package:KKB/providers/groups/selected_group.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// list of the group's settlements with their status, newest first
class PaymentHistoryCard extends ConsumerStatefulWidget {
  const PaymentHistoryCard({super.key});

  @override
  ConsumerState<PaymentHistoryCard> createState() => _PaymentHistoryCardState();
}

class _PaymentHistoryCardState extends ConsumerState<PaymentHistoryCard> {
  @override
  Widget build(BuildContext context) {
    final group = ref.watch(selectedGroupProvider);
    if (group == null) return const SizedBox.shrink();
    // the provider already keeps these newest first
    final settlements = ref.watch(groupSettlementsProvider(group.id));
    final userId = ref.watch(currentUserProvider)?.id ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        Text('Payment history', style: KKBTextStyles.titleSmall.copyWith(color: KKBColors.lightTextPrimary)),
        SettleCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: settlements.isEmpty
              ? const KKBEmptyState(title: 'No payments yet', subtitle: 'Recorded payments will show up here.')
              : Column(
                  children: [
                    for (var i = 0; i < settlements.length; i++) ...[if (i > 0) const Divider(height: 1, color: KKBColors.lightBorder), _HistoryRow(settlement: settlements[i], userId: userId)],
                  ],
                ),
        ),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.settlement, required this.userId});

  static final _dateFormat = DateFormat('MMM d');

  final Settlement settlement;
  final String userId;

  String _name(User user) => user.id == userId ? 'You' : user.firstName;

  @override
  Widget build(BuildContext context) {
    final (label, background, foreground) = switch (settlement.status) {
      'paid' => ('Paid', KKBColors.lightOwedBackground, KKBColors.lightOwed),
      'pending' => ('Pending', KKBColors.lightChip, KKBColors.lightTextPrimary),
      'rejected' => ('Rejected', KKBColors.lightOweBackground, KKBColors.lightOwe),
      _ => ('Unpaid', KKBColors.lightSurfaceVariant, KKBColors.lightTextSecondary),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_name(settlement.fromUser)} → ${_name(settlement.toUser)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: KKBTextStyles.bodyMediumBold.copyWith(color: KKBColors.lightTextPrimary),
                ),
                Text(_dateFormat.format(settlement.createdAt.toLocal()), style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 2,
            children: [
              Text(settleCurrency.format(settlement.amount), style: KKBTextStyles.bodyLargeXBold.copyWith(color: KKBColors.lightTextPrimary)),
              SettlePill(label: label, background: background, foreground: foreground),
            ],
          ),
        ],
      ),
    );
  }
}
