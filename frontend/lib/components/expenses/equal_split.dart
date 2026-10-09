import 'package:KKB/components/global/member_avatar.dart';
import 'package:KKB/components/expenses/add_expense_shared.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/models/user.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';

// "Split between" section: tick which members share the bill equally
class EqualSplit extends StatelessWidget {
  const EqualSplit({super.key, required this.members, required this.selectedIds, required this.equalShare, required this.onToggle});

  // all group members, the payer included since they pay their own share too
  final List<User> members;
  final Set<String> selectedIds;
  final double equalShare;
  final ValueChanged<String> onToggle;

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
            Text('${expenseCurrency.format(equalShare)} each', style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary)),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: expenseCardDecoration(),
          child: others.isEmpty
              ? Text(
                  'No members to split with.',
                  textAlign: TextAlign.center,
                  style: KKBTextStyles.bodySmall.copyWith(color: KKBColors.lightTextSecondary),
                )
              : Wrap(alignment: WrapAlignment.spaceAround, spacing: 8, runSpacing: 16, children: [for (final (index, member) in others) _buildSplitMember(member, index)]),
        ),
      ],
    );
  }

  Widget _buildSplitMember(User member, int colorIndex) {
    final selected = selectedIds.contains(member.id);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onToggle(member.id),
      child: SizedBox(
        width: 72,
        child: Column(
          spacing: 6,
          children: [
            Opacity(
              opacity: selected ? 1 : 0.4,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  MemberAvatar(user: member, colorIndex: colorIndex, size: 40),
                  if (selected)
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: KKBColors.lightPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(color: KKBColors.lightSurface, width: 2),
                        ),
                        child: const Icon(Icons.check_rounded, size: 12, color: KKBColors.lightOnPrimary),
                      ),
                    ),
                ],
              ),
            ),
            Text(
              selected ? expenseCurrency.format(equalShare) : '—',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: KKBTextStyles.bodyXSmallBold.copyWith(color: KKBColors.lightTextPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
