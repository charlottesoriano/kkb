import 'package:KKB/models/settlement_input.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/expense_input.freezed.dart';
part 'generated/expense_input.g.dart';

@freezed
abstract class ExpenseInput with _$ExpenseInput {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory ExpenseInput({
    required int groupId,
    required String paidBy,
    required String description,
    required double amount,
    @Default([]) List<SettlementInput> settlements,
  }) = _ExpenseInput;

  factory ExpenseInput.fromJson(Map<String, Object?> json) => _$ExpenseInputFromJson(json);
}
