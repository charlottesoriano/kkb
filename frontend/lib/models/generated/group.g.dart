// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Group _$GroupFromJson(Map<String, dynamic> json) => _Group(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  createdBy: json['created_by'] == null
      ? null
      : User.fromJson(json['created_by'] as Map<String, dynamic>),
  description: json['description'] as String? ?? "",
  members:
      (json['members'] as List<dynamic>?)
          ?.map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  expenses:
      (json['expenses'] as List<dynamic>?)
          ?.map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  isFavorite: json['is_favorite'] as bool? ?? false,
  createdAt: json['created_at'] as String? ?? "",
);

Map<String, dynamic> _$GroupToJson(_Group instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'created_by': instance.createdBy,
  'description': instance.description,
  'members': instance.members,
  'expenses': instance.expenses,
  'is_favorite': instance.isFavorite,
  'created_at': instance.createdAt,
};
