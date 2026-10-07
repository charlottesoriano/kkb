import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/models/user.dart';

part 'generated/balance.freezed.dart';
part 'generated/balance.g.dart';

@freezed
abstract class Balance with _$Balance {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Balance({
    required User user,
    required double amount,
  }) = _Balance;

  factory Balance.fromJson(Map<String, Object?> json) => _$BalanceFromJson(json);
}
