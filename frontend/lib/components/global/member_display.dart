import 'package:KKB/components/global/member_avatar.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/models/user.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';

// avatar + first name, laid out side by side (horizontal) or stacked (vertical)
class MemberDisplay extends StatelessWidget {
  const MemberDisplay({super.key, required this.user, this.isHorizontal = false, this.isSelected = false, this.isChecked = false, this.isMe = false, this.colorIndex = 0});

  final User user;
  final bool isHorizontal;
  final bool isSelected;
  final bool isChecked;
  final bool isMe;
  final int colorIndex;

  @override
  Widget build(BuildContext context) {
    final name = Text(
      isMe ? '${user.firstName} (you)' : user.firstName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: isHorizontal ? TextAlign.start : TextAlign.center,
      style: (isSelected ? KKBTextStyles.bodySmallBold : KKBTextStyles.bodySmall).copyWith(color: KKBColors.lightTextPrimary),
    );

    if (isHorizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          MemberAvatar(user: user, colorIndex: colorIndex, size: 28, selected: isSelected),
          Flexible(child: name),
        ],
      );
    }

    return SizedBox(
      width: 64,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          MemberAvatar(user: user, colorIndex: colorIndex, size: 52, selected: isSelected),
          name,
        ],
      ),
    );
  }
}
