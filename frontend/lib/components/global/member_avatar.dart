import 'package:KKB/const/colors.dart';
import 'package:KKB/models/user.dart';
import 'package:KKB/utils/helper.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';

class MemberAvatar extends StatelessWidget {
  const MemberAvatar({super.key, required this.user, this.size = 32, this.colorIndex = 0, this.selected = false, this.bordered = false});

  static const colors = [
    (KKBColors.lightAvatar1, KKBColors.lightOnAvatar1),
    (KKBColors.lightAvatar2, KKBColors.lightOnAvatar2),
    (KKBColors.lightAvatar3, KKBColors.lightOnAvatar3),
    (KKBColors.lightAvatar4, KKBColors.lightOnAvatar4),
  ];

  // the member's position in the group keeps their color the same across screens
  static int colorIndexIn(List<User> members, String userId) {
    final index = members.indexWhere((member) => member.id == userId);
    return index < 0 ? 0 : index;
  }

  final User user;
  final double size;
  final int colorIndex;
  // primary ring around the avatar, e.g. the selected payer
  final bool selected;
  // white ring separates overlapping circles
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final (avatarColor, onAvatarColor) = colors[colorIndex % colors.length];

    final circle = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: avatarColor,
        shape: BoxShape.circle,
        border: bordered ? Border.all(color: KKBColors.lightSurface, width: 2) : null,
      ),
      child: user.imageUrl.isEmpty
          ? _initials(onAvatarColor)
          : ClipOval(
              child: Image.network(
                user.imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                // fall back to initials if the image fails to load
                errorBuilder: (context, error, stackTrace) => _initials(onAvatarColor),
              ),
            ),
    );

    if (!selected) return circle;

    // selected ring: avatar -> white gap -> primary ring
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: KKBColors.lightPrimary, width: 2),
      ),
      child: circle,
    );
  }

  Widget _initials(Color color) {
    return Text(Helper.initials('${user.firstName} ${user.lastName}'), style: (size >= 48 ? KKBTextStyles.bodyMediumXBold : KKBTextStyles.bodyXSmallBold).copyWith(color: color));
  }
}
