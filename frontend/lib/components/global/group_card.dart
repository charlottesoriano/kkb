import 'package:KKB/components/global/member_avatar.dart';
import 'package:KKB/components/global/balance_label.dart';
import 'package:KKB/components/global/svg_icon.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/const/icons.dart';
import 'package:KKB/models/group.dart';
import 'package:KKB/models/user.dart';
import 'package:KKB/utils/helper.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';

class KKBGroupCard extends StatelessWidget {
  const KKBGroupCard({super.key, required this.group, this.balance = 0, this.isFavorite = false, this.pendingConfirmations = 0, this.width = 260, this.onTap, this.onToggleFavorite});

  final Group group;
  // positive = you're owed, negative = you owe
  final double balance;
  final bool isFavorite;
  // payments waiting on you to confirm; shows a chip when > 0
  final int pendingConfirmations;
  final double width;
  final VoidCallback? onTap;
  final VoidCallback? onToggleFavorite;

  static const _avatarColors = [
    (KKBColors.lightAvatar1, KKBColors.lightOnAvatar1),
    (KKBColors.lightAvatar4, KKBColors.lightOnAvatar4),
    (KKBColors.lightAvatar2, KKBColors.lightOnAvatar2),
    (KKBColors.lightAvatar3, KKBColors.lightOnAvatar3),
  ];
  static const int _maxVisibleMembers = 3;
  static const double _memberSize = 28;
  static const double _memberOverlap = 8;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: KKBColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: KKBColors.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // avatar + favorite toggle
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAvatar(),
                    const Spacer(),
                    // sits in the top row so the card height stays the same with or without it
                    if (pendingConfirmations > 0) ...[_buildPendingChip(), const SizedBox(width: 8)],
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onToggleFavorite,
                      child: SvgIcon(icon: isFavorite ? KKBIcons.starFilled : KKBIcons.starOutlined, color: isFavorite ? KKBColors.lightPrimary : KKBColors.lightTextSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // name + subtitle
                Text(
                  group.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: KKBTextStyles.bodyLargeXBold.copyWith(color: KKBColors.lightTextPrimary),
                ),
                Text(
                  // fall back to member count when the group has no description
                  group.description.isNotEmpty ? group.description : '${group.members.length} members',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: KKBTextStyles.bodySmall.copyWith(color: KKBColors.lightTextSecondary),
                ),
                const Spacer(),

                // balance + members
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: BalanceLabel(balance: balance, crossAxisAlignment: CrossAxisAlignment.start, labelStyle: KKBTextStyles.bodySmall, amountStyle: KKBTextStyles.headerSmall),
                    ),
                    _buildMembers(group.members),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final (avatarColor, onAvatarColor) = _avatarColors[group.id % _avatarColors.length];

    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: avatarColor, borderRadius: BorderRadius.circular(12)),
      child: Text(Helper.initials(group.name), style: KKBTextStyles.bodyMediumXBold.copyWith(color: onAvatarColor)),
    );
  }

  Widget _buildPendingChip() {
    final label = '$pendingConfirmations to confirm';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: KKBColors.lightChip, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: KKBTextStyles.bodyXSmallBold.copyWith(color: KKBColors.lightTextPrimary)),
    );
  }

  Widget _buildMembers(List<User> members) {
    final visible = members.take(_maxVisibleMembers).toList();
    final extra = members.length - visible.length;
    final count = visible.length + (extra > 0 ? 1 : 0);

    if (count == 0) return const SizedBox.shrink();

    const step = _memberSize - _memberOverlap;

    return SizedBox(
      width: _memberSize + (count - 1) * step,
      height: _memberSize,
      child: Stack(
        children: [
          for (var i = 0; i < visible.length; i++)
            Positioned(
              left: i * step,
              child: MemberAvatar(user: visible[i], size: _memberSize, colorIndex: i, bordered: true),
            ),
          if (extra > 0) Positioned(left: visible.length * step, child: _buildExtraCircle(extra)),
        ],
      ),
    );
  }

  // "+N" circle for members past the visible ones
  Widget _buildExtraCircle(int extra) {
    return Container(
      width: _memberSize,
      height: _memberSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: KKBColors.lightSurfaceVariant,
        shape: BoxShape.circle,
        // white ring separates overlapping circles
        border: Border.all(color: KKBColors.lightSurface, width: 2),
      ),
      child: Text('+$extra', style: KKBTextStyles.bodyXSmallBold.copyWith(color: KKBColors.lightTextPrimary)),
    );
  }
}
