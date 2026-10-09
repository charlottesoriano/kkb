import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/auth_session.freezed.dart';
part 'generated/auth_session.g.dart';

@freezed
abstract class AuthSession with _$AuthSession {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory AuthSession({
    @Default(false) bool isSignedIn,
    @Default(null) String? userId,
    @Default(null) String? email,
    @Default(false) bool loading,
    @Default(false) bool needsVerification,
    @Default(null) String? error,
  }) = _AuthSession;

  factory AuthSession.fromJson(Map<String, Object?> json) => _$AuthSessionFromJson(json);
}