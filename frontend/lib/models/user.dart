import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/user.freezed.dart';
part 'generated/user.g.dart';

@freezed
abstract class User with _$User {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory User({
    required String id,
    required String email,
    required String displayName,
    required String firstName,
    required String lastName,
    required String imageUrl,
    @Default("") String createdAt,
  }) = _User;

  factory User.fromJson(Map<String, Object?> json) => _$UserFromJson(json);
}
