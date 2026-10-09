import 'package:KKB/components/global/section_label.dart';
import 'package:KKB/components/global/card.dart';
import 'package:KKB/utils/helper.dart';
import 'package:KKB/components/global/empty_state.dart';
import 'package:KKB/components/global/member_avatar.dart';
import 'package:KKB/components/expenses/add_expense_shared.dart';
import 'package:KKB/components/global/status_chip.dart';
import 'package:KKB/components/global/text_field.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/models/user.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';

// "Split between" section for custom amounts: type how much each member owes
class CustomSplit extends StatelessWidget {
  const CustomSplit({super.key, required this.members, required this.controllers, required this.amount, required this.assigned, required this.onChanged});

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

    Widget memberRow(User member, int colorIndex) {
      return Row(
        spacing: 12,
        children: [
          MemberAvatar(user: member, colorIndex: colorIndex, size: 36),
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
              prefixIcon: Text('₱', style: KKBTextStyles.bodyMediumBold.copyWith(color: KKBColors.lightTextSecondary)),
              onChanged: (_) => onChanged(),
            ),
          ),
        ],
      );
    }

    // "₱3,600.00 of ₱3,600.00 assigned" + left/over pill
    Widget summary() {
      final remaining = amount - assigned;
      final balanced = remaining.abs() < 0.01;

      final pillText = balanced
          ? '${Helper.currency.format(0)} left'
          : remaining > 0
          ? '${Helper.currency.format(remaining)} left'
          : '${Helper.currency.format(remaining.abs())} over';

      return Row(
        spacing: 8,
        children: [
          Expanded(
            child: Text(
              '${Helper.currency.format(assigned)} of ${Helper.currency.format(amount)} assigned',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary),
            ),
          ),
          StatusChip(label: pillText, variant: balanced ? StatusChipVariant.success : StatusChipVariant.danger, icon: balanced ? Icons.check_rounded : null),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const KKBSectionLabel('Split between'),
            Text('Enter each share', style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary)),
          ],
        ),
        const SizedBox(height: 10),
        KKBCard(
          width: double.infinity,
          child: others.isEmpty
              ? const KKBEmptyState(title: 'No members to split with', subtitle: 'Invite members to the group to split expenses')
              : Column(
                  children: [
                    for (final (index, member) in others) ...[memberRow(member, index), const SizedBox(height: 10)],
                    const Divider(height: 16, color: KKBColors.lightBorder),
                    summary(),
                  ],
                ),
        ),
      ],
    );
  }
}
