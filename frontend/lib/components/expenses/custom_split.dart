import 'package:KKB/components/expenses/add_expense_shared.dart';
import 'package:KKB/components/global/text_field.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/models/user.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';

// "Split between" section for custom amounts: type how much each member owes
class CustomSplit extends StatelessWidget {
  const CustomSplit({
    super.key,
    required this.members,
    required this.controllers,
    required this.amount,
    required this.assigned,
    required this.onChanged,
  });

  // all group members, the payer included since they pay their own share too
  final List<User> members;
  // member id -> amount input
  final Map<String, TextEditingController> controllers;
  // expense total
  final double amount;
  // sum of the amounts typed so far
  final double assigned;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final others = members.indexed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const ExpenseSectionLabel('Split between'),
            Text(
              'Enter each share',
              style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: expenseCardDecoration(),
          child: others.isEmpty
              ? Text(
                  'No members to split with.',
                  textAlign: TextAlign.center,
                  style: KKBTextStyles.bodySmall.copyWith(color: KKBColors.lightTextSecondary),
                )
              : Column(
                  children: [
                    for (final (index, member) in others) ...[
                      _buildMemberRow(member, index),
                      const SizedBox(height: 10),
                    ],
                    const Divider(height: 16, color: KKBColors.lightBorder),
                    _buildSummary(),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildMemberRow(User member, int colorIndex) {
    return Row(
      spacing: 12,
      children: [
        ExpenseMemberAvatar(member: member, colorIndex: colorIndex, size: 36),
        Expanded(
          child: Text(
            member.firstName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: KKBTextStyles.bodyMediumSemiBold.copyWith(color: KKBColors.lightTextPrimary),
          ),
        ),
        SizedBox(
          width: 130,
          child: KKBTextField(
            type: KKBInputType.number,
            hintText: '0.00',
            controller: controllers[member.id],
            inputFormatters: [expenseAmountFormatter],
            backgroundColor: KKBColors.lightBackground,
            textAlign: TextAlign.end,
            textStyle: KKBTextStyles.bodyLargeBold,
            prefixIcon: Text(
              '₱',
              style: KKBTextStyles.bodyMediumBold.copyWith(color: KKBColors.lightTextSecondary),
            ),
            onChanged: (_) => onChanged(),
          ),
        ),
      ],
    );
  }

  // "₱3,600.00 of ₱3,600.00 assigned" + left/over pill
  Widget _buildSummary() {
    final remaining = amount - assigned;
    final balanced = remaining.abs() < 0.01;

    final pillText = balanced
        ? '${expenseCurrency.format(0)} left'
        : remaining > 0
            ? '${expenseCurrency.format(remaining)} left'
            : '${expenseCurrency.format(remaining.abs())} over';
    final foreground = balanced ? KKBColors.lightOwed : KKBColors.lightOwe;
    final background = balanced ? KKBColors.lightOwedBackground : KKBColors.lightOweBackground;

    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: Text(
            '${expenseCurrency.format(assigned)} of ${expenseCurrency.format(amount)} assigned',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              if (balanced) Icon(Icons.check_rounded, size: 14, color: foreground),
              Text(pillText, style: KKBTextStyles.bodyXSmallBold.copyWith(color: foreground)),
            ],
          ),
        ),
      ],
    );
  }
}
