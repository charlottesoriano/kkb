import 'package:KKB/models/group.dart';
import 'package:KKB/providers/balances/group_balances.dart';
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
    await ref.read(groupBalancesProvider.notifier).fetchGroupBalances(group.id);
    // await ref.read(groupBalancesProvider.notifier).fetchGroupBalances(group.id);
  }
}