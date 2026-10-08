import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/settlement_input.freezed.dart';
part 'generated/settlement_input.g.dart';

@freezed
abstract class SettlementInput with _$SettlementInput {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SettlementInput({
    required String fromUser,
    required String toUser,
    required double amount
  }) = _SettlementInput;

  factory SettlementInput.fromJson(Map<String, Object?> json) => _$SettlementInputFromJson(json);
}
