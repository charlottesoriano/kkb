import 'package:KKB/components/settle/settle_shared.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/models/expense.dart';
import 'package:KKB/models/group.dart';
import 'package:KKB/models/settlement.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';

// group total, how much is settled, and what each member paid vs. their share of the splits
class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, required this.group, required this.expenses, required this.settlements});

  static const _barColors = [KKBColors.lightCategory3, KKBColors.lightCategory2, KKBColors.lightCategory1, KKBColors.lightCategory4];

  // brand colors first, then generated ones so any number of members gets a distinct color;
  // stepping the hue by the golden angle (~137.5°) keeps neighbouring colors far apart
  static Color _barColor(int index) {
    if (index < _barColors.length) return _barColors[index];
    final hue = (index - _barColors.length) * 137.508 % 360;
    return HSLColor.fromAHSL(1, hue, 0.55, 0.5).toColor();
  }

  final Group group;
  final List<Expense> expenses;
  final List<Settlement> settlements;

  @override
  Widget build(BuildContext context) {
    final total = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final settled = settlements.where((s) => s.status == 'paid').fold(0.0, (sum, s) => sum + s.amount);
    final pendingCount = settlements.where((s) => s.status == 'unpaid' || s.status == 'pending').length;

    // per member: what they paid for expenses, their share of the splits, and paid settlements they sent
    final paid = <String, double>{};
    final share = <String, double>{};
    final sent = <String, double>{};
    for (final expense in expenses) {
      paid[expense.paidBy.id] = (paid[expense.paidBy.id] ?? 0) + expense.amount;
      for (final split in expense.splits) {
        share[split.user.id] = (share[split.user.id] ?? 0) + split.amount;
      }
    }
    for (final settlement in settlements) {
      if (settlement.status == 'paid') sent[settlement.fromUser.id] = (sent[settlement.fromUser.id] ?? 0) + settlement.amount;
    }

    // biggest payer first
    final members = [...group.members]..sort((a, b) => (paid[b.id] ?? 0).compareTo(paid[a.id] ?? 0));
    final maxPaid = paid.values.fold(0.0, (max, p) => p > max ? p : max);

    return SettleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Group summary', style: KKBTextStyles.bodySmall.copyWith(color: KKBColors.lightTextSecondary)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(settleCurrency.format(total), style: KKBTextStyles.displaySmall.copyWith(color: KKBColors.lightTextPrimary)),
          ),
          const SizedBox(height: 6),
          Text(
            '${expenses.length} expenses · ${settleCurrency.format(settled)} settled'
            '${pendingCount > 0 ? ' · $pendingCount pending' : ''}',
            style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary),
          ),
          const SizedBox(height: 16),
          Text('Paid by', style: KKBTextStyles.bodySmallBold.copyWith(color: KKBColors.lightTextPrimary)),
          const SizedBox(height: 8),
          for (var i = 0; i < members.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PaidByBar(
                name: members[i].firstName,
                paid: paid[members[i].id] ?? 0,
                share: share[members[i].id] ?? 0,
                settled: sent[members[i].id] ?? 0,
                fraction: maxPaid == 0 ? 0 : (paid[members[i].id] ?? 0) / maxPaid,
                // keyed by position in the group, so a member keeps their color when the ranking changes
                color: _barColor(group.members.indexWhere((m) => m.id == members[i].id)),
              ),
            ),
        ],
      ),
    );
  }
}

class _PaidByBar extends StatelessWidget {
  const _PaidByBar({required this.name, required this.paid, required this.share, required this.settled, required this.fraction, required this.color});

  final String name;
  final double paid;
  final double share;
  final double settled;
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: KKBTextStyles.bodyXSmallSemiBold.copyWith(color: KKBColors.lightTextPrimary)),
            Text(settleCurrency.format(paid), style: KKBTextStyles.bodyXSmallSemiBold.copyWith(color: KKBColors.lightTextPrimary)),
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(value: fraction, minHeight: 6, color: color, backgroundColor: KKBColors.lightSurfaceVariant),
        ),
        Text('Share ${settleCurrency.format(share)} · settled ${settleCurrency.format(settled)}', style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary)),
      ],
    );
  }
}
