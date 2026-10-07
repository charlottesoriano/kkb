import 'package:KKB/components/global/svg_icon.dart';
import 'package:KKB/const/icons.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/providers/global/preferred_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppNavigation extends ConsumerWidget {
  const AppNavigation({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

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

    final background = isDark ? KKBColors.darkBackground : KKBColors.lightBackground;
    final surface = isDark ? KKBColors.darkSurface : KKBColors.lightSurface;
    final border = isDark ? KKBColors.darkBorder : KKBColors.lightBorder;
    final inactive = isDark ? KKBColors.darkTextSecondary : KKBColors.lightTextSecondary;
    final active = isDark ? KKBColors.darkLink : KKBColors.lightLink;

    NavigationDestination destination(String icon, String label) {
      return NavigationDestination(
        icon: SvgIcon(icon: icon, color: inactive),
        selectedIcon: SvgIcon(icon: icon, color: active),
        label: label,
      );
    }

    return Scaffold(
      backgroundColor: background,
      body: navigationShell, // the current tab's page renders here
      bottomNavigationBar: DecoratedBox(
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
            destination(KKBIcons.wallet, 'Balances'),
            destination(KKBIcons.addCircle, 'Add'),
            destination(KKBIcons.settle, 'Settle up'),
            destination(KKBIcons.settings, 'Settings'),
          ],
        ),
      ),
    );
  }
}
