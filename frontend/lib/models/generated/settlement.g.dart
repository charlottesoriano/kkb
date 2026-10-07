// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../settlement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Settlement _$SettlementFromJson(Map<String, dynamic> json) => _Settlement(
  id: (json['id'] as num).toInt(),
  group_id: (json['group_id'] as num).toInt(),
  fromUser: User.fromJson(json['from_user'] as Map<String, dynamic>),
  toUser: User.fromJson(json['to_user'] as Map<String, dynamic>),
  amount: (json['amount'] as num).toDouble(),
  status: json['status'] as String? ?? "pending",
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$SettlementToJson(_Settlement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'group_id': instance.group_id,
      'from_user': instance.fromUser,
      'to_user': instance.toUser,
      'amount': instance.amount,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
    };
