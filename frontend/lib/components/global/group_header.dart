import 'package:KKB/components/global/group_header_bell.dart';
import 'package:KKB/components/global/group_header_card.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/models/group.dart';
import 'package:flutter/material.dart';

// app bar shared by the group screens: group chip (taps back to groups) on the left, notification bell on the right
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
          const Flexible(child: GroupHeaderCard()),
          const SizedBox(width: 12),
          GroupHeaderBell(hasNotifications: hasNotifications, onTap: onTapNotifications),
        ],
      ),
    );
  }
}
