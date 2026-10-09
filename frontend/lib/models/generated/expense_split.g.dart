// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../expense_split.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExpenseSplit _$ExpenseSplitFromJson(Map<String, dynamic> json) =>
    _ExpenseSplit(
      id: (json['id'] as num).toInt(),
      expenseId: (json['expense_id'] as num).toInt(),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$ExpenseSplitToJson(_ExpenseSplit instance) =>
    <String, dynamic>{
      'id': instance.id,
      'expense_id': instance.expenseId,
      'user': instance.user,
      'amount': instance.amount,
    };
