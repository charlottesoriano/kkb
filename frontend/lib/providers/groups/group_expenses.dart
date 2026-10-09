import 'package:KKB/models/expense.dart';
import 'package:KKB/models/expense_input.dart';
import 'package:KKB/models/expense_split.dart';
import 'package:KKB/models/response_status.dart';
import 'package:KKB/models/user.dart';
import 'package:KKB/providers/groups/group_balances.dart';
import 'package:KKB/providers/global/graphql_client.dart';
import 'package:KKB/utils/helper.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/group_expenses.g.dart';

//keep alive: screens only ref.read this, so it would be disposed mid-request
@Riverpod(keepAlive: true)
class GroupExpenses extends _$GroupExpenses {
  @override
  List<Expense> build() {
    return [];
  }

  // parse a user from the graphql response
  User parseUser(Map<String, dynamic> data) {
    return User(id: data['id'], email: data['email'], displayName: data['display_name'], firstName: data['first_name'], lastName: data['last_name'], imageUrl: data['image_url'] ?? '', createdAt: data['created_at'] ?? '');
  }

  // parse an expense from the graphql response
  Expense parseExpense(Map<String, dynamic> data) {
    final List<dynamic> splits = data['splits'] ?? [];
    return Expense(
      id: data['id'],
      groupId: data['group_id'],
      description: data['description'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      paidBy: parseUser(data['paid_by']),
      createdAt: data['created_at'] ?? '',
      splits: splits.map((split) => ExpenseSplit(
        id: split['id'],
        expenseId: split['expense_id'],
        user: parseUser(split['user']),
        amount: (split['amount'] as num?)?.toDouble() ?? 0,
      )).toList(),
    );
  }

  Future<ResponseStatus> fetchGroupExpenses(int groupId) => Helper.guard(() async {
    try {
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
              splits {
                id
                expense_id
                amount
                user {
                  id
                  email
                  display_name
                  first_name
                  last_name
                  image_url
                  created_at
                }
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
      final expenses = data.map((expense) => parseExpense(expense)).toList();
      state = expenses;
      
      return ResponseStatus(message: 'Expenses fetched successfully', status: true, body: expenses);
    } on Exception catch (e) {
      return ResponseStatus(message: e.toString(), status: false, body: {});
    }
  });

  Future<ResponseStatus> createExpense(ExpenseInput expenseInput) => Helper.guard(() async {
    final client = ref.read(graphqlClientProvider);
    final result = await client.mutate(
      MutationOptions(
        document: gql(r'''
          mutation CreateExpense($input: CreateExpenseInput!, $splits: [CreateExpenseSplitInput!]!) {
            createExpense(createExpenseInput: $input, splits: $splits) {
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
              splits {
                id
                expense_id
                amount
                user {
                  id
                  email
                  display_name
                  first_name
                  last_name
                  image_url
                  created_at
                }
              }
              created_at
            }
          }
        '''),
        variables: {
          //toJson gives snake_case keys matching CreateExpenseInput; splits go in their own argument
          "input": expenseInput.toJson()..remove('splits'),
          "splits": expenseInput.splits.map((split) => {"user_id": split.userId, "amount": split.amount}).toList(),
        },
      )
    );

    if (result.hasException) {
      return ResponseStatus(message: Helper.error(result), status: false, body: {});
    }

    final expense = parseExpense(result.data!['createExpense']);

    //newest first, same order as fetchGroupExpenses
    state = [expense, ...state];
    //the new splits change who owes what, so refresh the balances too
    await ref.read(groupBalancesProvider(expenseInput.groupId).notifier).fetchGroupBalances();

    return ResponseStatus(message: 'Expense created successfully', status: true, body: expense);
  });
}
