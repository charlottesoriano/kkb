import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:KKB/models/user.dart';
import 'package:KKB/models/expense_split.dart';
part 'generated/expense.freezed.dart';
part 'generated/expense.g.dart';

@freezed
abstract class Expense with _$Expense {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Expense({
    required int id,
    required User paidBy,
    required int groupId,
    @Default("") String description,
    @Default(0) double amount,
    @Default("") String createdAt,
    @Default([]) List<ExpenseSplit> splits,
  }) = _Expense;

  factory Expense.fromJson(Map<String, Object?> json) => _$ExpenseFromJson(json);
}
