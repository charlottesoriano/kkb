import 'package:KKB/models/balance.dart';
import 'package:KKB/models/response_status.dart';
import 'package:KKB/providers/global/graphql_client.dart';
import 'package:KKB/utils/helper.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/group_balances.g.dart';

//keep alive: screens only ref.read this, so it would be disposed mid-request
@Riverpod(keepAlive: true)
class GroupBalances extends _$GroupBalances {
  @override
  List<Balance> build() {
    return [];
  }

  Future<ResponseStatus> fetchGroupBalances(int groupId) => Helper.guard(() async {
    final client = ref.read(graphqlClientProvider);
    final result = await client.query(
      QueryOptions(
        document: gql(r'''
          query GroupBalances($groupId: Int!) {
            groupBalances(groupId: $groupId) {
              user_id
              balance
            }
          }
        '''),
        variables: {
          "groupId": groupId,
        },
        //always hit the server so balances reflect newly added expenses
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) {
      return ResponseStatus(message: Helper.error(result), status: false, body: {});
    }

    print('----> ${result.data}');
    // final data = result.data?['groupBalances'] ?? [];
    // final List<Balance> balances = data.map<Balance>((balance) => Balance.fromJson(balance)).toList();
    // state = balances;
    return ResponseStatus(message: 'Group balances fetched successfully', status: true, body: []);
  });
}