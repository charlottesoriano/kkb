import 'package:KKB/models/settlement.dart';
import 'package:KKB/models/settlement_input.dart';
import 'package:KKB/models/response_status.dart';
import 'package:KKB/models/user.dart';
import 'package:KKB/providers/groups/group_balances.dart';
import 'package:KKB/providers/global/graphql_client.dart';
import 'package:KKB/utils/helper.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/group_settlements.g.dart';

//one instance per group, so several groups' settlements (e.g. the favorites carousel) can be loaded at once
//keep alive: screens only ref.read this, so it would be disposed mid-request
@Riverpod(keepAlive: true)
class GroupSettlements extends _$GroupSettlements {
  @override
  List<Settlement> build(int groupId) {
    return [];
  }

  // parse a user from the graphql response
  User parseUser(Map<String, dynamic> data) {
    return User(id: data['id'], email: data['email'], displayName: data['display_name'], firstName: data['first_name'], lastName: data['last_name'], imageUrl: data['image_url'] ?? '', createdAt: data['created_at'] ?? '');
  }

  // parse a settlement from the graphql response
  Settlement parseSettlement(Map<String, dynamic> data) {
    return Settlement(
      id: data['id'],
      groupId: data['group_id'],
      fromUser: parseUser(data['from_user']),
      toUser: parseUser(data['to_user']),
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      status: data['status'] ?? 'unpaid',
      createdAt: DateTime.parse(data['created_at']),
    );
  }

  Future<ResponseStatus> fetchGroupSettlements() => Helper.guard(() async {
    final client = ref.read(graphqlClientProvider);
    final result = await client.query(
      QueryOptions(
        document: gql(r'''
          query Settlements($groupId: Int!) {
            settlements(groupId: $groupId) {
              id
              group_id
              from_user {
                id
                email
                display_name
                first_name
                last_name
                image_url
                created_at
              }
              to_user {
                id
                email
                display_name
                first_name
                last_name
                image_url
                created_at
              }
              amount
              status
              created_at
            }
          }
        '''),
        variables: {
          "groupId": groupId,
        },
        //always hit the server so newly created settlements show up
        fetchPolicy: FetchPolicy.networkOnly,
      )
    );

    if (result.hasException) {
      return ResponseStatus(message: Helper.error(result), status: false, body: {});
    }

    final List<dynamic> data = result.data?['settlements'] ?? [];
    //backend already orders by created_at descending
    final settlements = data.map((settlement) => parseSettlement(settlement)).toList();
    state = settlements;

    return ResponseStatus(message: 'Settlements fetched successfully', status: true, body: settlements);
  });

  //records a payment from one member to another; it starts as unpaid, so balances don't change yet
  Future<ResponseStatus> createSettlement(SettlementInput settlementInput) => Helper.guard(() async {
    final client = ref.read(graphqlClientProvider);
    final result = await client.mutate(
      MutationOptions(
        document: gql(r'''
          mutation CreateSettlement($input: CreateSettlementInput!) {
            createSettlement(createSettlementInput: $input) {
              id
              group_id
              from_user {
                id
                email
                display_name
                first_name
                last_name
                image_url
                created_at
              }
              to_user {
                id
                email
                display_name
                first_name
                last_name
                image_url
                created_at
              }
              amount
              status
              created_at
            }
          }
        '''),
        variables: {
          //toJson gives snake_case keys matching CreateSettlementInput
          "input": {...settlementInput.toJson(), "group_id": groupId},
        },
      )
    );

    if (result.hasException) {
      return ResponseStatus(message: Helper.error(result), status: false, body: {});
    }

    final settlement = parseSettlement(result.data!['createSettlement']);
    //newest first, same order as fetchGroupSettlements
    state = [settlement, ...state];

    return ResponseStatus(message: 'Settlement created successfully', status: true, body: settlement);
  });

  //records a payment the payer says they made; the server saves it as pending,
  //so balances don't change until the receiver confirms it with updateSettlementStatus
  Future<ResponseStatus> recordPayment(SettlementInput settlementInput) => Helper.guard(() async {
    final client = ref.read(graphqlClientProvider);
    final result = await client.mutate(
      MutationOptions(
        document: gql(r'''
          mutation RecordPayment($input: RecordPaymentInput!) {
            recordPayment(recordPaymentInput: $input) {
              id
              group_id
              from_user {
                id
                email
                display_name
                first_name
                last_name
                image_url
                created_at
              }
              to_user {
                id
                email
                display_name
                first_name
                last_name
                image_url
                created_at
              }
              amount
              status
              created_at
            }
          }
        '''),
        variables: {
          //toJson gives snake_case keys matching RecordPaymentInput
          "input": {...settlementInput.toJson(), "group_id": groupId},
        },
      )
    );

    if (result.hasException) {
      return ResponseStatus(message: Helper.error(result), status: false, body: {});
    }

    final settlement = parseSettlement(result.data!['recordPayment']);
    //newest first, same order as fetchGroupSettlements
    state = [settlement, ...state];

    return ResponseStatus(message: 'Payment recorded', status: true, body: settlement);
  });

  //marks a settlement as paid or rejected; only paid settlements count toward balances
  Future<ResponseStatus> updateSettlementStatus(Settlement settlement, String status) => Helper.guard(() async {
    final client = ref.read(graphqlClientProvider);
    final result = await client.mutate(
      MutationOptions(
        document: gql(r'''
          mutation UpdateSettlement($input: UpdateSettlementInput!) {
            updateSettlement(updateSettlementInput: $input) {
              id
              group_id
              from_user {
                id
                email
                display_name
                first_name
                last_name
                image_url
                created_at
              }
              to_user {
                id
                email
                display_name
                first_name
                last_name
                image_url
                created_at
              }
              amount
              status
              created_at
            }
          }
        '''),
        variables: {
          "input": {"id": settlement.id, "status": status},
        },
      )
    );

    if (result.hasException) {
      return ResponseStatus(message: Helper.error(result), status: false, body: {});
    }

    final updated = parseSettlement(result.data!['updateSettlement']);
    state = [for (final s in state) s.id == updated.id ? updated : s];
    //a settlement moving to or from paid changes who owes what
    await ref.read(groupBalancesProvider(groupId).notifier).fetchGroupBalances();

    return ResponseStatus(message: 'Settlement updated successfully', status: true, body: updated);
  });
}
