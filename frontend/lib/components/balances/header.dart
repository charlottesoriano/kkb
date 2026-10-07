import 'package:KKB/components/global/svg_icon.dart';
import 'package:KKB/components/global/title.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/const/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:KKB/utils/text_styles.dart';

class BalanceHeader extends ConsumerStatefulWidget {
  const BalanceHeader({super.key});

  /// Two lines at 28px (see [MTextStyles.headerLarge]) plus vertical padding inside the toolbar.
  static const double toolbarHeightForTwoLineTitle = 80;

  @override
  Size get preferredSize => const Size.fromHeight(toolbarHeightForTwoLineTitle);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BalanceHeaderState();
}

class _BalanceHeaderState extends ConsumerState<BalanceHeader> {

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: BalanceHeader.toolbarHeightForTwoLineTitle,
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
          KKBTitle(title: 'Balances'),
          Text('Tap a group to see its splits', style: KKBTextStyles.bodyMedium.copyWith(color: KKBColors.lightTextSecondary)),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: SvgIcon(icon: KKBIcons.add, color: Colors.white),
          style: IconButton.styleFrom(
            backgroundColor: KKBColors.lightPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}