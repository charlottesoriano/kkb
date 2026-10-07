import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:KKB/models/expense.dart';
import 'package:KKB/models/user.dart';

part 'generated/group.freezed.dart';
part 'generated/group.g.dart';

@freezed
abstract class Group with _$Group {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Group({
    required int id,
    required String name,
    required User createdBy,
    @Default("") String description,
    @Default([]) List<User> members,
    @Default([]) List<Expense> expenses,
  }) = _Group;

  factory Group.fromJson(Map<String, Object?> json) => _$GroupFromJson(json);
}
