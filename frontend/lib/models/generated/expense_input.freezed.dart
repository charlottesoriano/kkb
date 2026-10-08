// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../expense_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExpenseInput {

 int get groupId; String get paidBy; String get description; double get amount; List<SettlementInput> get settlements;
/// Create a copy of ExpenseInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseInputCopyWith<ExpenseInput> get copyWith => _$ExpenseInputCopyWithImpl<ExpenseInput>(this as ExpenseInput, _$identity);

  /// Serializes this ExpenseInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ExpenseInput;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpenseInput&&(identical(other.groupId, _this.groupId) || other.groupId == _this.groupId)&&(identical(other.paidBy, _this.paidBy) || other.paidBy == _this.paidBy)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&const DeepCollectionEquality().equals(other.settlements, _this.settlements));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExpenseInput;
  return Object.hash(runtimeType,_this.groupId,_this.paidBy,_this.description,_this.amount,const DeepCollectionEquality().hash(_this.settlements));
}

@override
String toString() {
  final _this = this as ExpenseInput;
  return 'ExpenseInput(groupId: ${_this.groupId}, paidBy: ${_this.paidBy}, description: ${_this.description}, amount: ${_this.amount}, settlements: ${_this.settlements})';
}


}

/// @nodoc
abstract mixin class $ExpenseInputCopyWith<$Res>  {
  factory $ExpenseInputCopyWith(ExpenseInput value, $Res Function(ExpenseInput) _then) = _$ExpenseInputCopyWithImpl;
@useResult
$Res call({
 int groupId, String paidBy, String description, double amount, List<SettlementInput> settlements
});




}
/// @nodoc
class _$ExpenseInputCopyWithImpl<$Res>
    implements $ExpenseInputCopyWith<$Res> {
  _$ExpenseInputCopyWithImpl(this._self, this._then);

  final ExpenseInput _self;
  final $Res Function(ExpenseInput) _then;

/// Create a copy of ExpenseInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? groupId = null,Object? paidBy = null,Object? description = null,Object? amount = null,Object? settlements = null,}) {
  return _then(ExpenseInput(
groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as int,paidBy: null == paidBy ? _self.paidBy : paidBy // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,settlements: null == settlements ? _self.settlements : settlements // ignore: cast_nullable_to_non_nullable
as List<SettlementInput>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpenseInput].
extension ExpenseInputPatterns on ExpenseInput {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpenseInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpenseInput() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpenseInput value)  $default,){
final _that = this;
switch (_that) {
case _ExpenseInput():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpenseInput value)?  $default,){
final _that = this;
switch (_that) {
case _ExpenseInput() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int groupId,  String paidBy,  String description,  double amount,  List<SettlementInput> settlements)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpenseInput() when $default != null:
return $default(_that.groupId,_that.paidBy,_that.description,_that.amount,_that.settlements);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int groupId,  String paidBy,  String description,  double amount,  List<SettlementInput> settlements)  $default,) {final _that = this;
switch (_that) {
case _ExpenseInput():
return $default(_that.groupId,_that.paidBy,_that.description,_that.amount,_that.settlements);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int groupId,  String paidBy,  String description,  double amount,  List<SettlementInput> settlements)?  $default,) {final _that = this;
switch (_that) {
case _ExpenseInput() when $default != null:
return $default(_that.groupId,_that.paidBy,_that.description,_that.amount,_that.settlements);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _ExpenseInput implements ExpenseInput {
  const _ExpenseInput({required this.groupId, required this.paidBy, required this.description, required this.amount,  List<SettlementInput> settlements = const []}): _settlements = settlements;
  factory _ExpenseInput.fromJson(Map<String, dynamic> json) => _$ExpenseInputFromJson(json);

@override final  int groupId;
@override final  String paidBy;
@override final  String description;
@override final  double amount;
 final  List<SettlementInput> _settlements;
@override@JsonKey() List<SettlementInput> get settlements {
  if (_settlements is EqualUnmodifiableListView) return _settlements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_settlements);
}


/// Create a copy of ExpenseInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpenseInputCopyWith<_ExpenseInput> get copyWith => __$ExpenseInputCopyWithImpl<_ExpenseInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpenseInputToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpenseInput&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.paidBy, paidBy) || other.paidBy == paidBy)&&(identical(other.description, description) || other.description == description)&&(identical(other.amount, amount) || other.amount == amount)&&const DeepCollectionEquality().equals(other.settlements, _settlements));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,groupId,paidBy,description,amount,const DeepCollectionEquality().hash(_settlements));
}

@override
String toString() {
    return 'ExpenseInput(groupId: $groupId, paidBy: $paidBy, description: $description, amount: $amount, settlements: $settlements)';
}


}

/// @nodoc
abstract mixin class _$ExpenseInputCopyWith<$Res> implements $ExpenseInputCopyWith<$Res> {
  factory _$ExpenseInputCopyWith(_ExpenseInput value, $Res Function(_ExpenseInput) _then) = __$ExpenseInputCopyWithImpl;
@override @useResult
$Res call({
 int groupId, String paidBy, String description, double amount, List<SettlementInput> settlements
});




}
/// @nodoc
class __$ExpenseInputCopyWithImpl<$Res>
    implements _$ExpenseInputCopyWith<$Res> {
  __$ExpenseInputCopyWithImpl(this._self, this._then);

  final _ExpenseInput _self;
  final $Res Function(_ExpenseInput) _then;

/// Create a copy of ExpenseInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? groupId = null,Object? paidBy = null,Object? description = null,Object? amount = null,Object? settlements = null,}) {
  return _then(_ExpenseInput(
groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as int,paidBy: null == paidBy ? _self.paidBy : paidBy // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,settlements: null == settlements ? _self._settlements : settlements // ignore: cast_nullable_to_non_nullable
as List<SettlementInput>,
  ));
}


}

// dart format on
