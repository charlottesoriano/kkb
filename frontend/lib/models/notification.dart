import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:KKB/models/user.dart';

part 'generated/notification.freezed.dart';
part 'generated/notification.g.dart';

@freezed
abstract class Notification with _$Notification {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Notification({
    required int id,
    required User fromUser,
    required User toUser,
    required String title,
    required String description,
    required String createdAt,
  }) = _Notification;

  factory Notification.fromJson(Map<String, Object?> json) => _$NotificationFromJson(json);
}
