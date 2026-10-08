import 'package:KKB/components/global/svg_icon.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/const/icons.dart';
import 'package:KKB/models/group.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';

// app bar shared by the group screens: group chip on the left, notification bell on the right
// usage: Scaffold(appBar: KKBGroupHeader(group: group))
class KKBGroupHeader extends StatelessWidget implements PreferredSizeWidget {
  const KKBGroupHeader({
    super.key,
    required this.group,
    this.hasNotifications = false,
    this.onTapGroup,
    this.onTapNotifications,
  });

  final Group group;
  // shows the red dot on the bell
  final bool hasNotifications;
  // e.g. open the group switcher
  final VoidCallback? onTapGroup;
  final VoidCallback? onTapNotifications;

  static const _avatarColors = [
    (KKBColors.lightAvatar1, KKBColors.lightOnAvatar1),
    (KKBColors.lightAvatar2, KKBColors.lightOnAvatar2),
    (KKBColors.lightAvatar3, KKBColors.lightOnAvatar3),
    (KKBColors.lightAvatar4, KKBColors.lightOnAvatar4),
  ];

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: KKBColors.lightBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: 16,
      toolbarHeight: preferredSize.height,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: _buildGroupChip()),
          const SizedBox(width: 12),
          _buildBell(),
        ],
      ),
    );
  }

  Widget _buildGroupChip() {
    final (avatarColor, onAvatarColor) = _avatarColors[group.id % _avatarColors.length];

    return Material(
      color: KKBColors.lightSurface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTapGroup,
        child: Container(
          padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: KKBColors.lightBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: avatarColor, borderRadius: BorderRadius.circular(10)),
                child: Text(
                  _initials(group.name),
                  style: KKBTextStyles.bodyXSmallBold.copyWith(color: onAvatarColor),
                ),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      group.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: KKBTextStyles.bodyMediumBold.copyWith(color: KKBColors.lightTextPrimary),
                    ),
                    Text(
                      '${group.members.length} members',
                      style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.grid_view_rounded, size: 16, color: KKBColors.lightTextSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBell() {
    return Material(
      color: KKBColors.lightSurface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTapNotifications,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: KKBColors.lightBorder),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const SvgIcon(icon: KKBIcons.bell, size: 20, color: KKBColors.lightTextPrimary),
              if (hasNotifications)
                Positioned(
                  top: -1,
                  right: -1,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: KKBColors.lightNotificationDot,
                      shape: BoxShape.circle,
                      border: Border.all(color: KKBColors.lightSurface, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // "Boracay 2026" -> "BO", "Casa Katipunan" -> "CK"
  String _initials(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '';
    if (words.length == 1 || !RegExp(r'^[A-Za-z]').hasMatch(words[1])) {
      return words.first.substring(0, words.first.length.clamp(0, 2)).toUpperCase();
    }
    return (words[0][0] + words[1][0]).toUpperCase();
  }
}
