// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Expense _$ExpenseFromJson(Map<String, dynamic> json) => _Expense(
  id: (json['id'] as num).toInt(),
  paidBy: User.fromJson(json['paid_by'] as Map<String, dynamic>),
  description: json['description'] as String? ?? "",
  amount: (json['amount'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$ExpenseToJson(_Expense instance) => <String, dynamic>{
  'id': instance.id,
  'paid_by': instance.paidBy,
  'description': instance.description,
  'amount': instance.amount,
};
