import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/models/expense.dart';
import 'package:frontend/models/user.dart';

part 'generated/settlement.freezed.dart';
part 'generated/settlement.g.dart';

@freezed
abstract class Settlement with _$Settlement {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Settlement({
    required int id,
    required int group_id,
    required User fromUser,
    required User toUser,
    required double amount,
    @Default("pending") String status,
    required DateTime createdAt,
  }) = _Settlement;

  factory Settlement.fromJson(Map<String, Object?> json) => _$SettlementFromJson(json);
}
