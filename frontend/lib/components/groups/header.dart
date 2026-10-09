import 'package:KKB/components/global/svg_icon.dart';
import 'package:KKB/components/global/title.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/const/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:KKB/utils/text_styles.dart';

class GroupsHeader extends ConsumerStatefulWidget {
  const GroupsHeader({super.key, required this.onAddGroup});

  final VoidCallback onAddGroup;

  static const double toolbarHeightForTwoLineTitle = 80;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GroupsHeaderState();
}

class _GroupsHeaderState extends ConsumerState<GroupsHeader> {

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: GroupsHeader.toolbarHeightForTwoLineTitle,
      centerTitle: false,
      backgroundColor: KKBColors.lightBackground,
      // Match icon/text defaults to page content; avoid same-as-bg (invisible defaults).
      foregroundColor: KKBColors.lightTextPrimary,
      // Material 3 tints AppBar surfaces; without this, backgroundColor looks wrong vs. body.
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      // Prevent default back button so title sits at the leading edge
      automaticallyImplyLeading: false,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        // Start aligns the back control with the first line when the title wraps.
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          KKBTitle(title: 'Groups'),
          Text('Tap a group to see its splits', style: KKBTextStyles.bodyMedium.copyWith(color: KKBColors.lightTextSecondary)),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: IconButton(
            onPressed: widget.onAddGroup,
            icon: SvgIcon(icon: KKBIcons.add, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: KKBColors.lightPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              )
            ),
          ),
        ),
      ],
    );
  }
}