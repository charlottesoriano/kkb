// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Expense _$ExpenseFromJson(Map<String, dynamic> json) => _Expense(
  id: (json['id'] as num).toInt(),
  paidBy: User.fromJson(json['paid_by'] as Map<String, dynamic>),
  groupId: (json['group_id'] as num).toInt(),
  description: json['description'] as String? ?? "",
  amount: (json['amount'] as num?)?.toDouble() ?? 0,
  createdAt: json['created_at'] as String? ?? "",
);

Map<String, dynamic> _$ExpenseToJson(_Expense instance) => <String, dynamic>{
  'id': instance.id,
  'paid_by': instance.paidBy,
  'group_id': instance.groupId,
  'description': instance.description,
  'amount': instance.amount,
  'created_at': instance.createdAt,
};
