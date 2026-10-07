import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/response_status.freezed.dart';
part 'generated/response_status.g.dart';

@freezed
abstract class ResponseStatus with _$ResponseStatus {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ResponseStatus({
    @Default(false) bool status,
    @Default(null) String? message,
    @Default(null) dynamic body,
  }) = _ResponseStatus;

  factory ResponseStatus.fromJson(Map<String, Object?> json) => _$ResponseStatusFromJson(json);
}