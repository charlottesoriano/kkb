// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Notification _$NotificationFromJson(Map<String, dynamic> json) =>
    _Notification(
      id: (json['id'] as num).toInt(),
      fromUser: User.fromJson(json['from_user'] as Map<String, dynamic>),
      toUser: User.fromJson(json['to_user'] as Map<String, dynamic>),
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$NotificationToJson(_Notification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'from_user': instance.fromUser,
      'to_user': instance.toUser,
      'title': instance.title,
      'description': instance.description,
      'created_at': instance.createdAt,
    };
