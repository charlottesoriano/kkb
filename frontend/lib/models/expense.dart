import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:KKB/models/user.dart';

part 'generated/expense.freezed.dart';
part 'generated/expense.g.dart';

@freezed
abstract class Expense with _$Expense {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Expense({
    required int id,
    required User paidBy,
    @Default("") String description,
    @Default(0) double amount
  }) = _Expense;

  factory Expense.fromJson(Map<String, Object?> json) => _$ExpenseFromJson(json);
}
