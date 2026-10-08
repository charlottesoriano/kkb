import 'package:KKB/components/balances/balances_shared.dart';
import 'package:KKB/components/balances/everyones_balance.dart';
import 'package:KKB/components/balances/invite_code_card.dart';
import 'package:KKB/components/balances/net_balance_card.dart';
import 'package:KKB/components/balances/suggested_payment_card.dart';
import 'package:KKB/components/global/group_header.dart';
import 'package:KKB/components/global/tile_card.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/models/balance.dart';
import 'package:KKB/models/group.dart';
import 'package:KKB/models/user.dart';
import 'package:KKB/providers/balances/group_balances.dart';
import 'package:KKB/providers/groups/selected_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BalancesIndex extends ConsumerStatefulWidget {
  const BalancesIndex({super.key});

  @override
  ConsumerState<BalancesIndex> createState() => _BalancesIndexState();
}

class _BalancesIndexState extends ConsumerState<BalancesIndex> {
  // TODO: replace the static data below with the balances / group queries
  static const _maya = User(id: 'maya', email: '', displayName: 'Maya', firstName: 'Maya', lastName: 'Santos', imageUrl: '');
  static const _paolo = User(id: 'paolo', email: '', displayName: 'Paolo', firstName: 'Paolo', lastName: 'Reyes', imageUrl: '');
  static const _ines = User(id: 'ines', email: '', displayName: 'Ines', firstName: 'Ines', lastName: 'Cruz', imageUrl: '');
  static const _jun = User(id: 'jun', email: '', displayName: 'Jun', firstName: 'Jun', lastName: 'Dela Cruz', imageUrl: '');

  static const _currentUserId = 'maya';
  static const _paymentsWithoutSimplify = 6;

  static const List<SuggestedPayment> _suggestedPayments = [
    (from: _maya, to: _paolo, amount: 5337.50),
    (from: _jun, to: _paolo, amount: 7737.50),
    (from: _ines, to: _paolo, amount: 3987.50),
  ];

  bool _simplifyDebts = true;

  @override
  Widget build(BuildContext context) {
    List<Balance> balances = ref.watch(groupBalancesProvider);
    Group? selectedGroup = ref.watch(selectedGroupProvider);
    final group = ref.watch(selectedGroupProvider);
    if (group == null) return const Scaffold(backgroundColor: KKBColors.lightBackground);

    // TODO: use ref.watch(currentUserProvider)?.id once the static data is replaced
    const userId = _currentUserId;

    final myBalance = balances.where((b) => b.user.id == userId).firstOrNull?.amount ?? 0;

    return Scaffold(
      backgroundColor: KKBColors.lightBackground,
      appBar: KKBGroupHeader(group: group, hasNotifications: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NetBalanceCard(balance: myBalance),
            const SizedBox(height: 12),
            InviteCodeCard(inviteCode: selectedGroup?.code ?? ''),
            const SizedBox(height: 12),
            // KKBTileCard(
            //   title: 'Simplify debts',
            //   subtitle: '${_suggestedPayments.length} payments instead of $_paymentsWithoutSimplify',
            //   trailing: Switch(
            //     value: _simplifyDebts,
            //     activeThumbColor: KKBColors.lightOnPrimary,
            //     activeTrackColor: KKBColors.lightPrimary,
            //     onChanged: (value) => setState(() => _simplifyDebts = value),
            //   ),
            // ),
            // const SizedBox(height: 20),

            const BalanceSectionLabel('Suggested payments (to-do)'),
            const SizedBox(height: 10),
            Column(
              spacing: 12,
              children: [
                for (final payment in _suggestedPayments)
                  SuggestedPaymentCard(group: group, payment: payment, userId: userId),
              ],
            ),
            const SizedBox(height: 20),

            const BalanceSectionLabel("Everyone's balance (to-do)"),
            const SizedBox(height: 10),
            EveryonesBalance(group: group, balances: balances, userId: userId),
          ],
        ),
      ),
    );
  }
}
