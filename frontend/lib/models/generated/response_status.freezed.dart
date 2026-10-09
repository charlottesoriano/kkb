// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../response_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ResponseStatus {

 bool get status; String? get message; dynamic get body;
/// Create a copy of ResponseStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResponseStatusCopyWith<ResponseStatus> get copyWith => _$ResponseStatusCopyWithImpl<ResponseStatus>(this as ResponseStatus, _$identity);

  /// Serializes this ResponseStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ResponseStatus;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResponseStatus&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.message, _this.message) || other.message == _this.message)&&const DeepCollectionEquality().equals(other.body, _this.body));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ResponseStatus;
  return Object.hash(runtimeType,_this.status,_this.message,const DeepCollectionEquality().hash(_this.body));
}

@override
String toString() {
  final _this = this as ResponseStatus;
  return 'ResponseStatus(status: ${_this.status}, message: ${_this.message}, body: ${_this.body})';
}


}

/// @nodoc
abstract mixin class $ResponseStatusCopyWith<$Res>  {
  factory $ResponseStatusCopyWith(ResponseStatus value, $Res Function(ResponseStatus) _then) = _$ResponseStatusCopyWithImpl;
@useResult
$Res call({
 bool status, String? message, dynamic body
});




}
/// @nodoc
class _$ResponseStatusCopyWithImpl<$Res>
    implements $ResponseStatusCopyWith<$Res> {
  _$ResponseStatusCopyWithImpl(this._self, this._then);

  final ResponseStatus _self;
  final $Res Function(ResponseStatus) _then;

/// Create a copy of ResponseStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? message = freezed,Object? body = freezed,}) {
  return _then(ResponseStatus(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// Adds pattern-matching-related methods to [ResponseStatus].
extension ResponseStatusPatterns on ResponseStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResponseStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResponseStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResponseStatus value)  $default,){
final _that = this;
switch (_that) {
case _ResponseStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResponseStatus value)?  $default,){
final _that = this;
switch (_that) {
case _ResponseStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool status,  String? message,  dynamic body)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResponseStatus() when $default != null:
return $default(_that.status,_that.message,_that.body);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool status,  String? message,  dynamic body)  $default,) {final _that = this;
switch (_that) {
case _ResponseStatus():
return $default(_that.status,_that.message,_that.body);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool status,  String? message,  dynamic body)?  $default,) {final _that = this;
switch (_that) {
case _ResponseStatus() when $default != null:
return $default(_that.status,_that.message,_that.body);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _ResponseStatus implements ResponseStatus {
  const _ResponseStatus({this.status = false, this.message = null, this.body = null});
  factory _ResponseStatus.fromJson(Map<String, dynamic> json) => _$ResponseStatusFromJson(json);

@override@JsonKey() final  bool status;
@override@JsonKey() final  String? message;
@override@JsonKey() final  dynamic body;

/// Create a copy of ResponseStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResponseStatusCopyWith<_ResponseStatus> get copyWith => __$ResponseStatusCopyWithImpl<_ResponseStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResponseStatusToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResponseStatus&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.body, body));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,status,message,const DeepCollectionEquality().hash(body));
}

@override
String toString() {
    return 'ResponseStatus(status: $status, message: $message, body: $body)';
}


}

/// @nodoc
abstract mixin class _$ResponseStatusCopyWith<$Res> implements $ResponseStatusCopyWith<$Res> {
  factory _$ResponseStatusCopyWith(_ResponseStatus value, $Res Function(_ResponseStatus) _then) = __$ResponseStatusCopyWithImpl;
@override @useResult
$Res call({
 bool status, String? message, dynamic body
});




}
/// @nodoc
class __$ResponseStatusCopyWithImpl<$Res>
    implements _$ResponseStatusCopyWith<$Res> {
  __$ResponseStatusCopyWithImpl(this._self, this._then);

  final _ResponseStatus _self;
  final $Res Function(_ResponseStatus) _then;

/// Create a copy of ResponseStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? message = freezed,Object? body = freezed,}) {
  return _then(_ResponseStatus(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

// dart format on
