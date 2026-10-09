import 'package:KKB/components/global/section_label.dart';
import 'package:KKB/components/global/card.dart';
import 'package:KKB/utils/helper.dart';
import 'package:KKB/components/global/empty_state.dart';
import 'package:KKB/components/expenses/equal_split_members.dart';
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
            const KKBSectionLabel('Split between'),
            Text('${Helper.currency.format(equalShare)} each', style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary)),
          ],
        ),
        const SizedBox(height: 10),
        KKBCard(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: others.isEmpty
              ? const KKBEmptyState(title: 'No members to split with', subtitle: 'Invite members to the group to split expenses')
              : Wrap(
                  alignment: WrapAlignment.spaceAround,
                  spacing: 8,
                  runSpacing: 16,
                  children: [
                    for (final (index, member) in others)
                      EqualSplitMember(
                        member: member,
                        colorIndex: index,
                        selected: selectedIds.contains(member.id),
                        equalShare: equalShare,
                        onTap: () => onToggle(member.id),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
