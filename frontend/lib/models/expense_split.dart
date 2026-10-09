import 'package:KKB/models/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/expense_split.freezed.dart';
part 'generated/expense_split.g.dart';

@freezed
abstract class ExpenseSplit with _$ExpenseSplit {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ExpenseSplit({
    required int id,
    required int expenseId,
    required User user,
    required double amount
  }) = _ExpenseSplit;

  factory ExpenseSplit.fromJson(Map<String, Object?> json) => _$ExpenseSplitFromJson(json);
}
