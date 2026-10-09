import 'package:KKB/components/global/button.dart';
import 'package:KKB/components/global/empty_state.dart';
import 'package:KKB/components/global/member_avatar.dart';
import 'package:KKB/components/global/group_header.dart';
import 'package:KKB/components/global/tile_card.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/core/router.dart';
import 'package:KKB/models/expense.dart';
import 'package:KKB/models/expense_split.dart';
import 'package:KKB/providers/auth/current_user.dart';
import 'package:KKB/providers/groups/group_expenses.dart';
import 'package:KKB/providers/groups/selected_group.dart';
import 'package:KKB/utils/helper.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ExpensesIndex extends ConsumerStatefulWidget {
  const ExpensesIndex({super.key});

  @override
  ConsumerState<ExpensesIndex> createState() => _ExpensesIndexState();
}

class _ExpensesIndexState extends ConsumerState<ExpensesIndex> {
  // only one card is open at a time
  int? _expandedId;

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(selectedGroupProvider);
    String userId = ref.watch(currentUserProvider)?.id ?? '';
    List<Expense> expenses = ref.watch(groupExpensesProvider);

    final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);

    void openAddExpense() {
      context.push(AppRoutes.addExpense);
    }

    void onTap(int id) {
      setState(() {
        _expandedId = _expandedId == id ? null : id;
      });
    }

    Widget buildUserBalance(Expense expense) {
      final balance = Helper.getUserBalance(expense, userId);
      final style = KKBTextStyles.bodySmall;
      if (balance > 0) return Text('You lent ${Helper.currency.format(balance)}', style: style.copyWith(color: KKBColors.lightTextSuccess));
      if (balance < 0) return Text('You owe ${Helper.currency.format(-balance)}', style: style.copyWith(color: KKBColors.lightTextError));
      return Text('Not involved', style: style.copyWith(color: KKBColors.lightTextSecondary));
    }

    // one row per member in the expense's splits; the payer's share is marked as paid
    Widget buildSplitRow(Expense expense, ExpenseSplit split) {
      final isPayer = split.user.id == expense.paidBy.id;
      final name = split.user.id == userId ? '${split.user.displayName} (you)' : split.user.displayName;

      return Row(
        spacing: 12,
        children: [
          MemberAvatar(user: split.user, colorIndex: MemberAvatar.colorIndexIn(group?.members ?? [], split.user.id)),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: KKBTextStyles.bodyMediumBold.copyWith(color: KKBColors.lightTextPrimary),
            ),
          ),
          if (isPayer)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: KKBColors.lightChip, borderRadius: BorderRadius.circular(12)),
              child: Text('Paid', style: KKBTextStyles.bodyXSmallSemiBold.copyWith(color: KKBColors.lightTextPrimary)),
            ),
          Text(Helper.currency.format(split.amount), style: KKBTextStyles.bodyMediumXBold.copyWith(color: KKBColors.lightTextPrimary)),
        ],
      );
    }

    // the expanded part of an expense card: how it was split, then each member's share
    List<Widget> buildSplits(Expense expense) {
      final splits = expense.splits;
      final isEqual = splits.isNotEmpty && splits.every((split) => split.amount == splits.first.amount);
      final labelStyle = KKBTextStyles.bodySmall.copyWith(color: KKBColors.lightTextSecondary);

      return [
        const Divider(height: 32, color: KKBColors.lightBorder),
        Row(
          children: [
            Expanded(child: Text(isEqual ? 'Split equally between ${splits.length}' : 'Split between ${splits.length}', style: labelStyle)),
            if (isEqual) Text('${Helper.currency.format(splits.first.amount)} each', style: labelStyle),
          ],
        ),
        const SizedBox(height: 12),
        Column(spacing: 16, children: [for (final split in splits) buildSplitRow(expense, split)]),
      ];
    }

    return Scaffold(
      backgroundColor: KKBColors.lightBackground,
      appBar: group == null ? null : KKBGroupHeader(hasNotifications: true),
      body: RefreshIndicator(
        onRefresh: () async {
          if (group != null) await ref.read(selectedGroupProvider.notifier).fetchGroupData(group);
        },
        child: SingleChildScrollView(
          // lets pull-to-refresh work even when the content is shorter than the screen
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Expenses', style: KKBTextStyles.headerXSmall.copyWith(color: KKBColors.lightTextPrimary)),
              const SizedBox(height: 4),
              Text('${expenses.length} expenses · ${Helper.currency.format(total)} total · tap one to see the split', style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary)),
              const SizedBox(height: 16),
              if (expenses.isEmpty)
                SizedBox(width: double.infinity, child: KKBEmptyState(title: 'No expenses yet', subtitle: 'Add an expense to get started'))
              else
                Column(
                  spacing: 12,
                  children: [
                    for (final expense in expenses)
                      KKBTileCard(
                        onTap: () => onTap(expense.id),
                        title: expense.description,
                        // subtitle: '${Helper.currency.format(expense.amount)} · ${DateTime.parse(expense.createdAt).toLocal().toString()}',
                        subtitle: 'Paid by ${expense.paidBy.displayName} · ${Helper.formatDate(expense.createdAt)}',
                        leading: MemberAvatar(user: expense.paidBy, size: 40, colorIndex: MemberAvatar.colorIndexIn(group?.members ?? [], expense.paidBy.id)),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(Helper.currency.format(expense.amount), style: KKBTextStyles.bodySmall.copyWith(color: KKBColors.lightTextSecondary)),
                            buildUserBalance(expense),
                          ],
                        ),
                        children: [if (_expandedId == expense.id) ...buildSplits(expense)],
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: KKBButton(label: 'Add expense', icon: Icons.add_rounded, size: KKBButtonSize.large, onPressed: openAddExpense),
          ),
        ),
      ),
    );
  }
}
