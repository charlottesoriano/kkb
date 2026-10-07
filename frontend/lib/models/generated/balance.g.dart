// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../balance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Balance _$BalanceFromJson(Map<String, dynamic> json) => _Balance(
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  amount: (json['amount'] as num).toDouble(),
);

Map<String, dynamic> _$BalanceToJson(_Balance instance) => <String, dynamic>{
  'user': instance.user,
  'amount': instance.amount,
};
