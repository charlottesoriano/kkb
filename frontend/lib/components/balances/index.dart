import 'package:KKB/components/balances/balances_shared.dart';
import 'package:KKB/components/balances/everyones_balance.dart';
import 'package:KKB/components/balances/invite_code_card.dart';
import 'package:KKB/components/balances/net_balance_card.dart';
import 'package:KKB/components/balances/suggested_payment_card.dart';
import 'package:KKB/components/global/group_header.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/models/balance.dart';
import 'package:KKB/models/expense.dart';
import 'package:KKB/models/settlement.dart';
import 'package:KKB/models/user.dart';
import 'package:KKB/providers/groups/group_balances.dart';
import 'package:KKB/providers/groups/group_expenses.dart';
import 'package:KKB/providers/groups/group_settlements.dart';
import 'package:KKB/providers/groups/selected_group.dart';
import 'package:KKB/providers/auth/current_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BalancesIndex extends ConsumerStatefulWidget {
  const BalancesIndex({super.key});

  @override
  ConsumerState<BalancesIndex> createState() => _BalancesIndexState();
}

class _BalancesIndexState extends ConsumerState<BalancesIndex> {
  // who still owes whom: each split is "split user owes the payer", paid settlements count the other way,
  // and debts between the same two people cancel out; whatever is left over is still pending
  List<SuggestedPayment> getSuggestedPayments(List<Expense> expenses, List<Settlement> settlements) {
    final users = <String, User>{};
    // "fromId|toId" -> total from has owed to
    final owed = <String, double>{};

    void addDebt(User from, User to, double amount) {
      users[from.id] = from;
      users[to.id] = to;
      owed['${from.id}|${to.id}'] = (owed['${from.id}|${to.id}'] ?? 0) + amount;
    }

    for (final expense in expenses) {
      for (final split in expense.splits) {
        // the payer's own share isn't owed to anyone
        if (split.user.id != expense.paidBy.id) addDebt(split.user, expense.paidBy, split.amount);
      }
    }
    // a paid settlement from A to B cancels that much of what A owes B
    for (final settlement in settlements) {
      if (settlement.status == 'paid') addDebt(settlement.toUser, settlement.fromUser, settlement.amount);
    }

    final payments = <SuggestedPayment>[];
    for (final MapEntry(key: key, value: amount) in owed.entries) {
      final [fromId, toId] = key.split('|');
      final net = amount - (owed['$toId|$fromId'] ?? 0);
      // only the direction that still owes is kept; skip anything under a centavo left from rounding
      if (net >= 0.01) payments.add((from: users[fromId]!, to: users[toId]!, amount: double.parse(net.toStringAsFixed(2))));
    }
    return payments;
  }

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(selectedGroupProvider);
    if (group == null) return const Scaffold(backgroundColor: KKBColors.lightBackground);
    List<Balance> balances = ref.watch(groupBalancesProvider(group.id));
    final userId = ref.watch(currentUserProvider)?.id ?? '';

    final myBalance = balances.where((b) => b.user.id == userId).firstOrNull?.amount ?? 0;
    // expenses are newest first, so these are the 3 most recent pending payments
    final suggestedPayments = getSuggestedPayments(ref.watch(groupExpensesProvider), ref.watch(groupSettlementsProvider(group.id))).take(3);

    return Scaffold(
      backgroundColor: KKBColors.lightBackground,
      appBar: KKBGroupHeader(hasNotifications: true),
      body: RefreshIndicator(
        onRefresh: () => ref.read(selectedGroupProvider.notifier).fetchGroupData(group),
        child: SingleChildScrollView(
          // lets pull-to-refresh work even when the content is shorter than the screen
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NetBalanceCard(balance: myBalance),
              const SizedBox(height: 12),
              InviteCodeCard(inviteCode: group.code),
              const SizedBox(height: 12),
              const BalanceSectionLabel('Suggested payments'),
              const SizedBox(height: 10),
              Column(
                spacing: 12,
                children: [for (final payment in suggestedPayments) SuggestedPaymentCard(group: group, payment: payment, userId: userId)],
              ),
              const SizedBox(height: 20),

              const BalanceSectionLabel("Everyone's balance"),
              const SizedBox(height: 10),
              EveryonesBalance(group: group, balances: balances, userId: userId),
            ],
          ),
        ),
      ),
    );
  }
}
