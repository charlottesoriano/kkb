import 'package:KKB/components/global/bottom_navigation.dart';
import 'package:KKB/const/icons.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/providers/groups/user_groups.dart';
import 'package:KKB/providers/global/notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// main navigation shown on launch: Groups / Settings
class AppNavigation extends ConsumerStatefulWidget {
  const AppNavigation({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends ConsumerState<AppNavigation> with WidgetsBindingObserver {
  StatefulNavigationShell get navigationShell => widget.navigationShell;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializedUserData();
    });
  }

  Future<void> _initializedUserData() async {
    // ref.read(userGroupsProvider.notifier).fetchUserGroups();
    // ref.read(notificationsProvider.notifier).fetchUserNotifications();
    await Future.wait([
      ref.read(userGroupsProvider.notifier).fetchUserGroups(),
      ref.read(notificationsProvider.notifier).fetchUserNotifications(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final background = KKBColors.lightBackground;

    return Scaffold(
      backgroundColor: background,
      body: navigationShell, // the current tab's page renders here
      bottomNavigationBar: KKBBottomNavigation(
        navigationShell: navigationShell,
        items: const [
          (KKBIcons.groups, 'Groups'),
          (KKBIcons.settings, 'Settings'),
        ],
      ),
    );
  }
}
