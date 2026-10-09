import 'package:KKB/components/global/member_avatar.dart';
import 'package:KKB/components/settle/settle_shared.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/models/settlement.dart';
import 'package:KKB/providers/auth/current_user.dart';
import 'package:KKB/providers/groups/group_settlements.dart';
import 'package:KKB/providers/groups/selected_group.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:KKB/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// payments others say they made to the current user, waiting to be confirmed or rejected
class ConfirmationCard extends ConsumerStatefulWidget {
  const ConfirmationCard({super.key});

  @override
  ConsumerState<ConfirmationCard> createState() => _ConfirmationCardState();
}

class _ConfirmationCardState extends ConsumerState<ConfirmationCard> {
  // settlement being confirmed/rejected, so its buttons can be disabled meanwhile
  int? _busyId;

  Future<void> _respond(Settlement settlement, String status) async {
    setState(() => _busyId = settlement.id);
    final result = await ref.read(groupSettlementsProvider(settlement.groupId).notifier).updateSettlementStatus(settlement, status);
    if (!mounted) return;
    setState(() => _busyId = null);
    if (!result.status && context.mounted) {
      Helper.showErrorSnackBar(context, result.message, action: DbAction.update);
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(selectedGroupProvider);
    if (group == null) return const SizedBox.shrink();
    final userId = ref.watch(currentUserProvider)?.id ?? '';
    // the provider already keeps these newest first
    final pending = ref.watch(groupSettlementsProvider(group.id)).where((s) => s.status == 'pending' && s.toUser.id == userId).toList();
    if (pending.isEmpty) return const SizedBox.shrink();

    return SettleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Needs your confirmation', style: KKBTextStyles.titleXSmall.copyWith(color: KKBColors.lightTextPrimary)),
              SettlePill(label: '${pending.length} pending', background: KKBColors.lightOweBackground, foreground: KKBColors.lightOwe),
            ],
          ),
          for (var i = 0; i < pending.length && i < 3; i++) ...[
            if (i > 0) const Divider(height: 1, color: KKBColors.lightBorder),
            _PendingRow(
              settlement: pending[i],
              busy: _busyId == pending[i].id,
              onReject: _busyId == null ? () => _respond(pending[i], 'rejected') : null,
              onConfirm: _busyId == null ? () => _respond(pending[i], 'paid') : null,
            ),
          ],
        ],
      ),
    );
  }
}

class _PendingRow extends StatelessWidget {
  const _PendingRow({required this.settlement, required this.busy, required this.onReject, required this.onConfirm});

  static final _dateFormat = DateFormat('MMM d');

  final Settlement settlement;
  final bool busy;
  final VoidCallback? onReject;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final from = settlement.fromUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Row(
          spacing: 12,
          children: [
            MemberAvatar(user: from, size: 36),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${from.firstName} says they paid you',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: KKBTextStyles.bodyMediumBold.copyWith(color: KKBColors.lightTextPrimary),
                  ),
                  Text('${_dateFormat.format(settlement.createdAt.toLocal())} · waiting for your confirmation', style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary)),
                ],
              ),
            ),
            Text(settleCurrency.format(settlement.amount), style: KKBTextStyles.bodyLargeXBold.copyWith(color: KKBColors.lightTextPrimary)),
          ],
        ),
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: SettleButton(label: busy ? '...' : 'Reject', filled: false, onPressed: onReject),
            ),
            Expanded(
              child: SettleButton(label: busy ? '...' : 'Confirm', onPressed: onConfirm),
            ),
          ],
        ),
      ],
    );
  }
}
