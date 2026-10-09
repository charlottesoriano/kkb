// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Notification {

 int get id; User get fromUser; User get toUser; String get title; String get description; String get createdAt;
/// Create a copy of Notification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationCopyWith<Notification> get copyWith => _$NotificationCopyWithImpl<Notification>(this as Notification, _$identity);

  /// Serializes this Notification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Notification;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Notification&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.fromUser, _this.fromUser) || other.fromUser == _this.fromUser)&&(identical(other.toUser, _this.toUser) || other.toUser == _this.toUser)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Notification;
  return Object.hash(runtimeType,_this.id,_this.fromUser,_this.toUser,_this.title,_this.description,_this.createdAt);
}

@override
String toString() {
  final _this = this as Notification;
  return 'Notification(id: ${_this.id}, fromUser: ${_this.fromUser}, toUser: ${_this.toUser}, title: ${_this.title}, description: ${_this.description}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $NotificationCopyWith<$Res>  {
  factory $NotificationCopyWith(Notification value, $Res Function(Notification) _then) = _$NotificationCopyWithImpl;
@useResult
$Res call({
 int id, User fromUser, User toUser, String title, String description, String createdAt
});


$UserCopyWith<$Res> get fromUser;$UserCopyWith<$Res> get toUser;

}
/// @nodoc
class _$NotificationCopyWithImpl<$Res>
    implements $NotificationCopyWith<$Res> {
  _$NotificationCopyWithImpl(this._self, this._then);

  final Notification _self;
  final $Res Function(Notification) _then;

/// Create a copy of Notification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fromUser = null,Object? toUser = null,Object? title = null,Object? description = null,Object? createdAt = null,}) {
  return _then(Notification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,fromUser: null == fromUser ? _self.fromUser : fromUser // ignore: cast_nullable_to_non_nullable
as User,toUser: null == toUser ? _self.toUser : toUser // ignore: cast_nullable_to_non_nullable
as User,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of Notification
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get fromUser {
  
  return $UserCopyWith<$Res>(_self.fromUser, (value) {
    return _then(_self.copyWith(fromUser: value));
  });
}/// Create a copy of Notification
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get toUser {
  
  return $UserCopyWith<$Res>(_self.toUser, (value) {
    return _then(_self.copyWith(toUser: value));
  });
}
}


/// Adds pattern-matching-related methods to [Notification].
extension NotificationPatterns on Notification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Notification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Notification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Notification value)  $default,){
final _that = this;
switch (_that) {
case _Notification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Notification value)?  $default,){
final _that = this;
switch (_that) {
case _Notification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  User fromUser,  User toUser,  String title,  String description,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Notification() when $default != null:
return $default(_that.id,_that.fromUser,_that.toUser,_that.title,_that.description,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  User fromUser,  User toUser,  String title,  String description,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _Notification():
return $default(_that.id,_that.fromUser,_that.toUser,_that.title,_that.description,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  User fromUser,  User toUser,  String title,  String description,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Notification() when $default != null:
return $default(_that.id,_that.fromUser,_that.toUser,_that.title,_that.description,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _Notification implements Notification {
  const _Notification({required this.id, required this.fromUser, required this.toUser, required this.title, required this.description, required this.createdAt});
  factory _Notification.fromJson(Map<String, dynamic> json) => _$NotificationFromJson(json);

@override final  int id;
@override final  User fromUser;
@override final  User toUser;
@override final  String title;
@override final  String description;
@override final  String createdAt;

/// Create a copy of Notification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationCopyWith<_Notification> get copyWith => __$NotificationCopyWithImpl<_Notification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Notification&&(identical(other.id, id) || other.id == id)&&(identical(other.fromUser, fromUser) || other.fromUser == fromUser)&&(identical(other.toUser, toUser) || other.toUser == toUser)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,fromUser,toUser,title,description,createdAt);
}

@override
String toString() {
    return 'Notification(id: $id, fromUser: $fromUser, toUser: $toUser, title: $title, description: $description, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$NotificationCopyWith<$Res> implements $NotificationCopyWith<$Res> {
  factory _$NotificationCopyWith(_Notification value, $Res Function(_Notification) _then) = __$NotificationCopyWithImpl;
@override @useResult
$Res call({
 int id, User fromUser, User toUser, String title, String description, String createdAt
});


@override $UserCopyWith<$Res> get fromUser;@override $UserCopyWith<$Res> get toUser;

}
/// @nodoc
class __$NotificationCopyWithImpl<$Res>
    implements _$NotificationCopyWith<$Res> {
  __$NotificationCopyWithImpl(this._self, this._then);

  final _Notification _self;
  final $Res Function(_Notification) _then;

/// Create a copy of Notification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fromUser = null,Object? toUser = null,Object? title = null,Object? description = null,Object? createdAt = null,}) {
  return _then(_Notification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,fromUser: null == fromUser ? _self.fromUser : fromUser // ignore: cast_nullable_to_non_nullable
as User,toUser: null == toUser ? _self.toUser : toUser // ignore: cast_nullable_to_non_nullable
as User,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of Notification
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get fromUser {
  
  return $UserCopyWith<$Res>(_self.fromUser, (value) {
    return _then(_self.copyWith(fromUser: value));
  });
}/// Create a copy of Notification
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get toUser {
  
  return $UserCopyWith<$Res>(_self.toUser, (value) {
    return _then(_self.copyWith(toUser: value));
  });
}
}

// dart format on
