import 'package:KKB/components/global/svg_icon.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/providers/global/preferred_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// bottom navigation bar shared by the main and group navigations
// items: list of (icon, label)
class KKBBottomNavigation extends ConsumerWidget {
  const KKBBottomNavigation({super.key, required this.navigationShell, required this.items});

  final StatefulNavigationShell navigationShell;
  final List<(String icon, String label)> items;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      // Tapping the tab you're already on pops it back to its root page
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(preferredModeProvider) == 'dark';

    final surface = isDark ? KKBColors.darkSurface : KKBColors.lightSurface;
    final border = isDark ? KKBColors.darkBorder : KKBColors.lightBorder;
    final inactive = isDark ? KKBColors.darkTextSecondary : KKBColors.lightTextSecondary;
    final active = isDark ? KKBColors.darkLink : KKBColors.lightLink;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: border)),
      ),
      child: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        height: 72,
        elevation: 0,
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent, // no M3 pill behind the active icon
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: states.contains(WidgetState.selected) ? active : inactive,
          ),
        ),
        destinations: [
          for (final (icon, label) in items)
            NavigationDestination(
              icon: SvgIcon(icon: icon, color: inactive),
              selectedIcon: SvgIcon(icon: icon, color: active),
              label: label,
            ),
        ],
      ),
    );
  }
}
