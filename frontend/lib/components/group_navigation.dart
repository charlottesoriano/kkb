import 'package:KKB/components/global/bottom_navigation.dart';
import 'package:KKB/const/icons.dart';
import 'package:KKB/const/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// group navigation shown after a group is selected: Balances / Expenses / Settle up
class GroupNavigation extends ConsumerWidget {
  const GroupNavigation({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final background = KKBColors.lightBackground;

    return Scaffold(
      backgroundColor: background,
      body: navigationShell, // the current tab's page renders here
      bottomNavigationBar: KKBBottomNavigation(
        navigationShell: navigationShell,
        items: const [
          (KKBIcons.wallet, 'Balances'),
          (KKBIcons.expenses, 'Expenses'),
          (KKBIcons.settle, 'Settle up'),
        ],
      ),
    );
  }
}
