import 'package:KKB/models/balance.dart';
import 'package:KKB/models/response_status.dart';
import 'package:KKB/models/user.dart';
import 'package:KKB/providers/global/graphql_client.dart';
import 'package:KKB/utils/helper.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/group_balances.g.dart';

//one instance per group, so several groups' balances (e.g. the favorites carousel) can be loaded at once
//keep alive: screens only ref.read this, so it would be disposed mid-request
@Riverpod(keepAlive: true)
class GroupBalances extends _$GroupBalances {
  @override
  List<Balance> build(int groupId) {
    return [];
  }

  Future<ResponseStatus> fetchGroupBalances() => Helper.guard(() async {
    final client = ref.read(graphqlClientProvider);
    final result = await client.query(
      QueryOptions(
        document: gql(r'''
          query GroupBalances($groupId: Int!) {
            groupBalances(groupId: $groupId) {
              user {
                id
                email
                display_name
                first_name
                last_name
                image_url
                created_at
              }
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

    final data = result.data?['groupBalances'] as List? ?? [];
    final balances = data
        .map<Balance>((b) => Balance(
              user: User.fromJson(b['user']),
              groupId: groupId,
              amount: (b['balance'] as num).toDouble(),
            ))
        .toList();
    state = balances;
    return ResponseStatus(message: 'Group balances fetched successfully', status: true, body: balances);
  });
}