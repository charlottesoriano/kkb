// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../expense_split_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExpenseSplitInput _$ExpenseSplitInputFromJson(Map<String, dynamic> json) =>
    _ExpenseSplitInput(
      userId: json['user_id'] as String,
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$ExpenseSplitInputToJson(_ExpenseSplitInput instance) =>
    <String, dynamic>{'user_id': instance.userId, 'amount': instance.amount};
