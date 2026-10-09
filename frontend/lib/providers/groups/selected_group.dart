import 'package:KKB/models/group.dart';
import 'package:KKB/providers/groups/group_balances.dart';
import 'package:KKB/providers/groups/group_expenses.dart';
import 'package:KKB/providers/groups/group_settlements.dart';
import 'package:KKB/providers/groups/user_groups.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/selected_group.g.dart';

@Riverpod(keepAlive: true)
class SelectedGroup extends _$SelectedGroup {
  @override
  Group? build() {
    return null;
  }

  Future<void> setSelectedGroup(Group group) async {
    state = group;

    //fetch the group balances
    // await ref.read(groupBalancesProvider.notifier).fetchGroupBalances(group.id);
    // await ref.read(groupExpensesProvider.notifier).fetchGroupExpenses(group.id);
    await _fetchGroupDetails(group);
  }

  //replaces the selected group with a fresher copy of the same group (e.g. after someone joined)
  void syncGroup(Group group) {
    if (state?.id == group.id) state = group;
  }

  //pull-to-refresh: also reload the groups so the member list is up to date
  Future<void> fetchGroupData(Group group) async {
    await Future.wait([
      ref.read(userGroupsProvider.notifier).fetchUserGroups(),
      _fetchGroupDetails(group),
    ]);
  }

  Future<void> _fetchGroupDetails(Group group) async {
    await Future.wait([
      ref.read(groupBalancesProvider(group.id).notifier).fetchGroupBalances(),
      ref.read(groupExpensesProvider.notifier).fetchGroupExpenses(group.id),
      ref.read(groupSettlementsProvider(group.id).notifier).fetchGroupSettlements(),
    ]);
  }
}