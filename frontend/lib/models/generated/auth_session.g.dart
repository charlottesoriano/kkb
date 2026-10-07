// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../auth_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthSession _$AuthSessionFromJson(Map<String, dynamic> json) => _AuthSession(
  isSignedIn: json['is_signed_in'] as bool? ?? false,
  userId: json['user_id'] as String? ?? null,
  email: json['email'] as String? ?? null,
  loading: json['loading'] as bool? ?? false,
  needsVerification: json['needs_verification'] as bool? ?? false,
  error: json['error'] as String? ?? null,
);

Map<String, dynamic> _$AuthSessionToJson(_AuthSession instance) =>
    <String, dynamic>{
      'is_signed_in': instance.isSignedIn,
      'user_id': instance.userId,
      'email': instance.email,
      'loading': instance.loading,
      'needs_verification': instance.needsVerification,
      'error': instance.error,
    };
