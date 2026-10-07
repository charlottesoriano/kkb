import 'package:KKB/components/expenses/add_expenses.dart';
import 'package:KKB/components/navigation.dart';
import 'package:KKB/components/balances/index.dart';
import 'package:KKB/components/settings/index.dart';
import 'package:KKB/components/signin/index.dart';
import 'package:KKB/components/settle/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:KKB/core/auth.dart';
import 'package:go_router/go_router.dart';

/// Route paths in one place so you never mistype them
class AppRoutes {
  static const login = '/login';
  static const balances = '/balances';
  static const add = '/add';
  static const settle = '/settle';
  static const settings = '/settings';

  /// Helper for the parameterised route: context.push(AppRoutes.splitDetailsFor(id))
  static String splitDetailsFor(String expenseId) => '/expenses/$expenseId';
}

final routerProvider = Provider<GoRouter>((ref) {
  final clerk = ref.read(clerkProvider);

  return GoRouter(
    initialLocation: AppRoutes.balances,

    // ClerkAuthState is a ChangeNotifier, so the router re-runs `redirect`
    // every time the user signs in or out.
    refreshListenable: clerk,

    redirect: (context, state) {
      final signedIn = clerk.isSignedIn;
      final onLogin = state.matchedLocation == AppRoutes.login;

      if (!signedIn && !onLogin) return AppRoutes.login;
      if (signedIn && onLogin) return AppRoutes.balances;
      return null; // no redirect
    },

    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const SigninIndex(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppNavigation(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.balances,
              builder: (context, state) => const BalancesIndex(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.add,
              builder: (context, state) => const AddExpensesWidget(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.settle,
              builder: (context, state) => const SettleIndex(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.settings,
              builder: (context, state) => const SettingsIndex(),
            ),
          ]),
        ]      
      )
    ],
  );
});