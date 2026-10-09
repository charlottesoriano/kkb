import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/expense_split_input.freezed.dart';
part 'generated/expense_split_input.g.dart';

@freezed
abstract class ExpenseSplitInput with _$ExpenseSplitInput {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ExpenseSplitInput({
    required String userId,
    required double amount
  }) = _ExpenseSplitInput;

  factory ExpenseSplitInput.fromJson(Map<String, Object?> json) => _$ExpenseSplitInputFromJson(json);
}
