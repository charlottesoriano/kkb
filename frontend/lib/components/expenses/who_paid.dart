import 'package:KKB/components/global/member_display.dart';
import 'package:KKB/models/user.dart';
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
              child: MemberDisplay(user: member, isSelected: member.id == paidById, isMe: member.id == userId, colorIndex: index),
            ),
        ],
      ),
    );
  }
}
