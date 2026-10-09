import 'package:KKB/components/global/member_avatar.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/models/user.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';

// horizontal list of members to pick who paid
class WhoPaid extends StatelessWidget {
  const WhoPaid({super.key, required this.members, required this.paidById, required this.userId, required this.onSelect});

  final List<User> members;
  final String? paidById;
  // signed-in user, labelled "(you)"
  final String? userId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 16,
        children: [
          for (final (index, member) in members.indexed)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelect(member.id),
              child: SizedBox(
                width: 64,
                child: Column(
                  spacing: 6,
                  children: [
                    MemberAvatar(user: member, colorIndex: index, size: 52, selected: member.id == paidById),
                    Text(
                      member.id == userId ? '${member.firstName} (you)' : member.firstName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: (member.id == paidById ? KKBTextStyles.bodySmallBold : KKBTextStyles.bodySmall).copyWith(color: KKBColors.lightTextPrimary),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
