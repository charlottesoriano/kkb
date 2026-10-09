// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../balance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Balance _$BalanceFromJson(Map<String, dynamic> json) => _Balance(
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  groupId: (json['group_id'] as num).toInt(),
  amount: (json['amount'] as num).toDouble(),
);

Map<String, dynamic> _$BalanceToJson(_Balance instance) => <String, dynamic>{
  'user': instance.user,
  'group_id': instance.groupId,
  'amount': instance.amount,
};
