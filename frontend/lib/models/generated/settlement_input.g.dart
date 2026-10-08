// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../settlement_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SettlementInput _$SettlementInputFromJson(Map<String, dynamic> json) =>
    _SettlementInput(
      fromUser: json['from_user'] as String,
      toUser: json['to_user'] as String,
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$SettlementInputToJson(_SettlementInput instance) =>
    <String, dynamic>{
      'from_user': instance.fromUser,
      'to_user': instance.toUser,
      'amount': instance.amount,
    };
