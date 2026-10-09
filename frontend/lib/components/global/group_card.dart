import 'package:KKB/components/global/member_avatar.dart';
import 'package:KKB/components/global/balance_label.dart';
import 'package:KKB/components/global/status_chip.dart';
import 'package:KKB/components/global/svg_icon.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/const/icons.dart';
import 'package:KKB/models/group.dart';
import 'package:KKB/models/user.dart';
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
  
  static const int maxVisibleMembers = 3;
  static const double memberSize = 28;
  static const double memberOverlap = 8;

  @override
  Widget build(BuildContext context) { 
    Widget buildExtraCircle(int extra) {
      return Container(
        width: memberSize,
        height: memberSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: KKBColors.lightSurfaceVariant,
          shape: BoxShape.circle,
          border: Border.all(color: KKBColors.lightSurface, width: 2),
        ),
        child: Text('+$extra', style: KKBTextStyles.bodyXSmallBold.copyWith(color: KKBColors.lightTextPrimary)),
      );
    }

    Widget buildMembers(List<User> members) {
      final visible = members.take(maxVisibleMembers).toList();
      final extra = members.length - visible.length;
      final count = visible.length + (extra > 0 ? 1 : 0);

      if (count == 0) return const SizedBox.shrink();

      const step = memberSize - memberOverlap;

      return SizedBox(
        width: memberSize + (count - 1) * step,
        height: memberSize,
        child: Stack(
          children: [
            for (var i = 0; i < visible.length; i++)
              Positioned(
                left: i * step,
                child: MemberAvatar(user: visible[i], size: memberSize, colorIndex: i, bordered: true),
              ),
            if (extra > 0) Positioned(left: visible.length * step, child: buildExtraCircle(extra)),
          ],
        ),
      );
    }

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
                    MemberAvatar.named(name: group.name, size: 48, colorIndex: group.id),
                    const Spacer(),
                    // sits in the top row so the card height stays the same with or without it
                    if (pendingConfirmations > 0) ...[StatusChip(label: '$pendingConfirmations to confirm'), const SizedBox(width: 8)],
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
                    buildMembers(group.members),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  
}
