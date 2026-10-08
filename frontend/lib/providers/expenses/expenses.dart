import 'package:KKB/models/expense.dart';
import 'package:KKB/models/expense_input.dart';
import 'package:KKB/models/response_status.dart';
import 'package:KKB/models/user.dart';
import 'package:KKB/providers/balances/group_balances.dart';
import 'package:KKB/providers/global/graphql_client.dart';
import 'package:KKB/utils/helper.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/expenses.g.dart';

//keep alive: screens only ref.read this, so it would be disposed mid-request
@Riverpod(keepAlive: true)
class GroupExpenses extends _$GroupExpenses {
  @override
  List<Expense> build() {
    return [];
  }

  // parse an expense from the graphql response
  Expense _parseExpense(Map<String, dynamic> data) {
    final paidBy = data['paid_by'];
    return Expense(
      id: data['id'],
      groupId: data['group_id'],
      description: data['description'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      paidBy: User(id: paidBy['id'], email: paidBy['email'], displayName: paidBy['display_name'], firstName: paidBy['first_name'], lastName: paidBy['last_name'], imageUrl: paidBy['image_url'] ?? '', createdAt: paidBy['created_at'] ?? ''),
      createdAt: data['created_at'] ?? '',
    );
  }

  Future<ResponseStatus> fetchGroupExpenses(int groupId) => Helper.guard(() async {
    final client = ref.read(graphqlClientProvider);
    final result = await client.query(
      QueryOptions(
        document: gql(r'''
          query Expenses($groupId: Int!) {
            expenses(groupId: $groupId) {
              id
              group_id
              description
              amount
              paid_by {
                id
                email
                display_name
                first_name
                last_name
                image_url
                created_at
              }
              created_at
            }
          }
        '''),
        variables: {
          "groupId": groupId,
        },
        //always hit the server so newly added expenses show up
        fetchPolicy: FetchPolicy.networkOnly,
      )
    );

    if (result.hasException) {
      return ResponseStatus(message: Helper.error(result), status: false, body: {});
    }

    final List<dynamic> data = result.data?['expenses'] ?? [];
    //backend already orders by created_at descending
    final expenses = data.map((expense) => _parseExpense(expense)).toList();
    state = expenses;

    return ResponseStatus(message: 'Expenses fetched successfully', status: true, body: expenses);
  });

  //creates the expense, then one settlement per split; rolls everything back if a settlement fails
  Future<ResponseStatus> createExpense(ExpenseInput expenseInput) => Helper.guard(() async {
    final client = ref.read(graphqlClientProvider);
    final result = await client.mutate(
      MutationOptions(
        document: gql(r'''
          mutation CreateExpense($input: CreateExpenseInput!) {
            createExpense(createExpenseInput: $input) {
              id
              group_id
              description
              amount
              paid_by {
                id
                email
                display_name
                first_name
                last_name
                image_url
                created_at
              }
              created_at
            }
          }
        '''),
        variables: {
          //toJson gives snake_case keys matching CreateExpenseInput; settlements are created separately below
          "input": expenseInput.toJson()..remove('settlements'),
        },
      )
    );

    if (result.hasException) {
      return ResponseStatus(message: Helper.error(result), status: false, body: {});
    }

    final expense = _parseExpense(result.data!['createExpense']);

    final createdSettlementIds = <int>[];
    for (final settlement in expenseInput.settlements) {
      final settlementResult = await client.mutate(
        MutationOptions(
          document: gql(r'''
            mutation CreateSettlement($input: CreateSettlementInput!) {
              createSettlement(createSettlementInput: $input) {
                id
              }
            }
          '''),
          variables: {
            "input": {...settlement.toJson(), "group_id": expenseInput.groupId},
          },
        )
      );

      if (settlementResult.hasException) {
        await _rollbackExpense(expense.id, createdSettlementIds);
        return ResponseStatus(message: Helper.error(settlementResult), status: false, body: {});
      }
      createdSettlementIds.add(settlementResult.data!['createSettlement']['id']);
    }

    //newest first, same order as fetchGroupExpenses
    state = [expense, ...state];
    //the new settlements change who owes what, so refresh the balances too
    await ref.read(groupBalancesProvider.notifier).fetchGroupBalances(expenseInput.groupId);

    return ResponseStatus(message: 'Expense created successfully', status: true, body: expense);
  });

  //best-effort cleanup when creating an expense's settlements fails partway
  Future<void> _rollbackExpense(int expenseId, List<int> settlementIds) async {
    final client = ref.read(graphqlClientProvider);
    for (final id in settlementIds) {
      await client.mutate(
        MutationOptions(
          document: gql(r'''
            mutation RemoveSettlement($id: Int!) {
              removeSettlement(id: $id) { id }
            }
          '''),
          variables: { "id": id },
        )
      );
    }
    await client.mutate(
      MutationOptions(
        document: gql(r'''
          mutation RemoveExpense($id: Int!) {
            removeExpense(id: $id) { id }
          }
        '''),
        variables: { "id": expenseId },
      )
    );
  }
}
