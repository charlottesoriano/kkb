// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../settlement_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SettlementInput {

 String get fromUser; String get toUser; double get amount;
/// Create a copy of SettlementInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettlementInputCopyWith<SettlementInput> get copyWith => _$SettlementInputCopyWithImpl<SettlementInput>(this as SettlementInput, _$identity);

  /// Serializes this SettlementInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SettlementInput;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettlementInput&&(identical(other.fromUser, _this.fromUser) || other.fromUser == _this.fromUser)&&(identical(other.toUser, _this.toUser) || other.toUser == _this.toUser)&&(identical(other.amount, _this.amount) || other.amount == _this.amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SettlementInput;
  return Object.hash(runtimeType,_this.fromUser,_this.toUser,_this.amount);
}

@override
String toString() {
  final _this = this as SettlementInput;
  return 'SettlementInput(fromUser: ${_this.fromUser}, toUser: ${_this.toUser}, amount: ${_this.amount})';
}


}

/// @nodoc
abstract mixin class $SettlementInputCopyWith<$Res>  {
  factory $SettlementInputCopyWith(SettlementInput value, $Res Function(SettlementInput) _then) = _$SettlementInputCopyWithImpl;
@useResult
$Res call({
 String fromUser, String toUser, double amount
});




}
/// @nodoc
class _$SettlementInputCopyWithImpl<$Res>
    implements $SettlementInputCopyWith<$Res> {
  _$SettlementInputCopyWithImpl(this._self, this._then);

  final SettlementInput _self;
  final $Res Function(SettlementInput) _then;

/// Create a copy of SettlementInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fromUser = null,Object? toUser = null,Object? amount = null,}) {
  return _then(SettlementInput(
fromUser: null == fromUser ? _self.fromUser : fromUser // ignore: cast_nullable_to_non_nullable
as String,toUser: null == toUser ? _self.toUser : toUser // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [SettlementInput].
extension SettlementInputPatterns on SettlementInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettlementInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettlementInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettlementInput value)  $default,){
final _that = this;
switch (_that) {
case _SettlementInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettlementInput value)?  $default,){
final _that = this;
switch (_that) {
case _SettlementInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fromUser,  String toUser,  double amount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettlementInput() when $default != null:
return $default(_that.fromUser,_that.toUser,_that.amount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fromUser,  String toUser,  double amount)  $default,) {final _that = this;
switch (_that) {
case _SettlementInput():
return $default(_that.fromUser,_that.toUser,_that.amount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fromUser,  String toUser,  double amount)?  $default,) {final _that = this;
switch (_that) {
case _SettlementInput() when $default != null:
return $default(_that.fromUser,_that.toUser,_that.amount);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _SettlementInput implements SettlementInput {
  const _SettlementInput({required this.fromUser, required this.toUser, required this.amount});
  factory _SettlementInput.fromJson(Map<String, dynamic> json) => _$SettlementInputFromJson(json);

@override final  String fromUser;
@override final  String toUser;
@override final  double amount;

/// Create a copy of SettlementInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettlementInputCopyWith<_SettlementInput> get copyWith => __$SettlementInputCopyWithImpl<_SettlementInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SettlementInputToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettlementInput&&(identical(other.fromUser, fromUser) || other.fromUser == fromUser)&&(identical(other.toUser, toUser) || other.toUser == toUser)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,fromUser,toUser,amount);
}

@override
String toString() {
    return 'SettlementInput(fromUser: $fromUser, toUser: $toUser, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$SettlementInputCopyWith<$Res> implements $SettlementInputCopyWith<$Res> {
  factory _$SettlementInputCopyWith(_SettlementInput value, $Res Function(_SettlementInput) _then) = __$SettlementInputCopyWithImpl;
@override @useResult
$Res call({
 String fromUser, String toUser, double amount
});




}
/// @nodoc
class __$SettlementInputCopyWithImpl<$Res>
    implements _$SettlementInputCopyWith<$Res> {
  __$SettlementInputCopyWithImpl(this._self, this._then);

  final _SettlementInput _self;
  final $Res Function(_SettlementInput) _then;

/// Create a copy of SettlementInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fromUser = null,Object? toUser = null,Object? amount = null,}) {
  return _then(_SettlementInput(
fromUser: null == fromUser ? _self.fromUser : fromUser // ignore: cast_nullable_to_non_nullable
as String,toUser: null == toUser ? _self.toUser : toUser // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
