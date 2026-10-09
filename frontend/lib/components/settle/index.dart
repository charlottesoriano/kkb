import 'package:KKB/components/global/group_header.dart';
import 'package:KKB/components/settle/confirmation_card.dart';
import 'package:KKB/components/settle/payment_history_card.dart';
import 'package:KKB/components/settle/record_payment_card.dart';
import 'package:KKB/components/settle/summary_card.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/providers/auth/current_user.dart';
import 'package:KKB/providers/groups/group_expenses.dart';
import 'package:KKB/providers/groups/group_settlements.dart';
import 'package:KKB/providers/groups/selected_group.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettleIndex extends ConsumerWidget {
  const SettleIndex({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(selectedGroupProvider);
    if (group == null) return const Scaffold(backgroundColor: KKBColors.lightBackground);

    return Scaffold(
      backgroundColor: KKBColors.lightBackground,
      appBar: KKBGroupHeader(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            Text('Settle up', style: KKBTextStyles.headerMedium.copyWith(color: KKBColors.lightTextPrimary)),
            SummaryCard(group: group, expenses: ref.watch(groupExpensesProvider), settlements: ref.watch(groupSettlementsProvider(group.id))),
            const ConfirmationCard(),
            RecordPaymentCard(members: group.members, userId: ref.watch(currentUserProvider)?.id ?? ''),
            const PaymentHistoryCard(),
          ],
        ),
      ),
    );
  }
}
