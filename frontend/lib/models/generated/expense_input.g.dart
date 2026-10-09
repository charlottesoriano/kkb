// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../expense_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExpenseInput _$ExpenseInputFromJson(Map<String, dynamic> json) =>
    _ExpenseInput(
      groupId: (json['group_id'] as num).toInt(),
      paidBy: json['paid_by'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      splits:
          (json['splits'] as List<dynamic>?)
              ?.map(
                (e) => ExpenseSplitInput.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ExpenseInputToJson(_ExpenseInput instance) =>
    <String, dynamic>{
      'group_id': instance.groupId,
      'paid_by': instance.paidBy,
      'description': instance.description,
      'amount': instance.amount,
      'splits': instance.splits.map((e) => e.toJson()).toList(),
    };
