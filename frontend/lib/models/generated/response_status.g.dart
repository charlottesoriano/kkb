// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../response_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ResponseStatus _$ResponseStatusFromJson(Map<String, dynamic> json) =>
    _ResponseStatus(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? null,
      body: json['body'] ?? null,
    );

Map<String, dynamic> _$ResponseStatusToJson(_ResponseStatus instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'body': instance.body,
    };
