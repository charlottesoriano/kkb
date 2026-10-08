import 'package:KKB/components/expenses/add_expenses.dart';
import 'package:KKB/components/expenses/index.dart';
import 'package:KKB/components/navigation.dart';
import 'package:KKB/components/group_navigation.dart';
import 'package:KKB/components/groups/index.dart';
import 'package:KKB/components/balances/index.dart';
import 'package:KKB/components/settings/index.dart';
import 'package:KKB/components/signin/index.dart';
import 'package:KKB/components/settle/index.dart';
import 'package:KKB/providers/groups/selected_group.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:KKB/core/auth.dart';
import 'package:go_router/go_router.dart';

/// Route paths in one place so you never mistype them
class AppRoutes {
  static const login = '/login';

  // main navigation
  static const groups = '/groups';
  static const settings = '/settings';

  // group navigation (opened after selecting a group)
  static const groupBalances = '/group/balances';
  static const groupExpenses = '/group/expenses';
  static const groupSettle = '/group/settle';
  static const addExpense = '/group/expenses/add';

  /// Helper for the parameterised route: context.push(AppRoutes.splitDetailsFor(id))
  static String splitDetailsFor(String expenseId) => '/group/expenses/$expenseId';
}

// root navigator, used by routes that should cover the bottom navigation
final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final clerk = ref.read(clerkProvider);


  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.groups,

    // ClerkAuthState is a ChangeNotifier, so the router re-runs `redirect`
    // every time the user signs in or out.
    refreshListenable: clerk,

    redirect: (context, state) {
      final signedIn = clerk.isSignedIn;
      final location = state.matchedLocation;
      final onLogin = location == AppRoutes.login;

      if (!signedIn && !onLogin) return AppRoutes.login;
      if (signedIn && onLogin) return AppRoutes.groups;

      // group screens need a selected group (e.g. after a hot restart there is none)
      if (location.startsWith('/group/') && ref.read(selectedGroupProvider) == null) {
        return AppRoutes.groups;
      }
      return null; // no redirect
    },

    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const SigninIndex(),
      ),

      // main navigation: Groups / Settings
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppNavigation(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.groups,
              builder: (context, state) => const GroupsIndex(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.settings,
              builder: (context, state) => const SettingsIndex(),
            ),
          ]),
        ],
      ),

      // group navigation: Balances / Expenses / Settle up
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => GroupNavigation(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.groupBalances,
              builder: (context, state) => const BalancesIndex(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.groupExpenses,
              builder: (context, state) => const ExpensesIndex(),
              routes: [
                GoRoute(
                  path: 'add', // -> /group/expenses/add
                  parentNavigatorKey: _rootNavigatorKey, // full screen, hides the bottom navigation
                  builder: (context, state) => const AddExpensesIndex(),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.groupSettle,
              builder: (context, state) => const SettleIndex(),
            ),
          ]),
        ],
      ),
    ],
  );
});
