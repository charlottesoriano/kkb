// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../expense_split.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExpenseSplit {

 int get id; int get expenseId; User get user; double get amount;
/// Create a copy of ExpenseSplit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseSplitCopyWith<ExpenseSplit> get copyWith => _$ExpenseSplitCopyWithImpl<ExpenseSplit>(this as ExpenseSplit, _$identity);

  /// Serializes this ExpenseSplit to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ExpenseSplit;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpenseSplit&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.expenseId, _this.expenseId) || other.expenseId == _this.expenseId)&&(identical(other.user, _this.user) || other.user == _this.user)&&(identical(other.amount, _this.amount) || other.amount == _this.amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExpenseSplit;
  return Object.hash(runtimeType,_this.id,_this.expenseId,_this.user,_this.amount);
}

@override
String toString() {
  final _this = this as ExpenseSplit;
  return 'ExpenseSplit(id: ${_this.id}, expenseId: ${_this.expenseId}, user: ${_this.user}, amount: ${_this.amount})';
}


}

/// @nodoc
abstract mixin class $ExpenseSplitCopyWith<$Res>  {
  factory $ExpenseSplitCopyWith(ExpenseSplit value, $Res Function(ExpenseSplit) _then) = _$ExpenseSplitCopyWithImpl;
@useResult
$Res call({
 int id, int expenseId, User user, double amount
});


$UserCopyWith<$Res> get user;

}
/// @nodoc
class _$ExpenseSplitCopyWithImpl<$Res>
    implements $ExpenseSplitCopyWith<$Res> {
  _$ExpenseSplitCopyWithImpl(this._self, this._then);

  final ExpenseSplit _self;
  final $Res Function(ExpenseSplit) _then;

/// Create a copy of ExpenseSplit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? expenseId = null,Object? user = null,Object? amount = null,}) {
  return _then(ExpenseSplit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,expenseId: null == expenseId ? _self.expenseId : expenseId // ignore: cast_nullable_to_non_nullable
as int,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of ExpenseSplit
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [ExpenseSplit].
extension ExpenseSplitPatterns on ExpenseSplit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpenseSplit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpenseSplit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpenseSplit value)  $default,){
final _that = this;
switch (_that) {
case _ExpenseSplit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpenseSplit value)?  $default,){
final _that = this;
switch (_that) {
case _ExpenseSplit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int expenseId,  User user,  double amount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpenseSplit() when $default != null:
return $default(_that.id,_that.expenseId,_that.user,_that.amount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int expenseId,  User user,  double amount)  $default,) {final _that = this;
switch (_that) {
case _ExpenseSplit():
return $default(_that.id,_that.expenseId,_that.user,_that.amount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int expenseId,  User user,  double amount)?  $default,) {final _that = this;
switch (_that) {
case _ExpenseSplit() when $default != null:
return $default(_that.id,_that.expenseId,_that.user,_that.amount);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _ExpenseSplit implements ExpenseSplit {
  const _ExpenseSplit({required this.id, required this.expenseId, required this.user, required this.amount});
  factory _ExpenseSplit.fromJson(Map<String, dynamic> json) => _$ExpenseSplitFromJson(json);

@override final  int id;
@override final  int expenseId;
@override final  User user;
@override final  double amount;

/// Create a copy of ExpenseSplit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpenseSplitCopyWith<_ExpenseSplit> get copyWith => __$ExpenseSplitCopyWithImpl<_ExpenseSplit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpenseSplitToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpenseSplit&&(identical(other.id, id) || other.id == id)&&(identical(other.expenseId, expenseId) || other.expenseId == expenseId)&&(identical(other.user, user) || other.user == user)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,expenseId,user,amount);
}

@override
String toString() {
    return 'ExpenseSplit(id: $id, expenseId: $expenseId, user: $user, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$ExpenseSplitCopyWith<$Res> implements $ExpenseSplitCopyWith<$Res> {
  factory _$ExpenseSplitCopyWith(_ExpenseSplit value, $Res Function(_ExpenseSplit) _then) = __$ExpenseSplitCopyWithImpl;
@override @useResult
$Res call({
 int id, int expenseId, User user, double amount
});


@override $UserCopyWith<$Res> get user;

}
/// @nodoc
class __$ExpenseSplitCopyWithImpl<$Res>
    implements _$ExpenseSplitCopyWith<$Res> {
  __$ExpenseSplitCopyWithImpl(this._self, this._then);

  final _ExpenseSplit _self;
  final $Res Function(_ExpenseSplit) _then;

/// Create a copy of ExpenseSplit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? expenseId = null,Object? user = null,Object? amount = null,}) {
  return _then(_ExpenseSplit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,expenseId: null == expenseId ? _self.expenseId : expenseId // ignore: cast_nullable_to_non_nullable
as int,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of ExpenseSplit
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
