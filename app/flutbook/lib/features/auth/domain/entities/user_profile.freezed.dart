// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) {
  return _UserProfile.fromJson(json);
}

/// @nodoc
mixin _$UserProfile {
  String get id => throw _privateConstructorUsedError;
  String get email =>
      throw _privateConstructorUsedError; // Default values allow you to avoid null checks in UI
  String get authMethod => throw _privateConstructorUsedError;
  bool get syncEnabled => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  DateTime? get lastSyncAt => throw _privateConstructorUsedError;
  String? get localLibraryPath => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserProfileCopyWith<UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
          UserProfile value, $Res Function(UserProfile) then) =
      _$UserProfileCopyWithImpl<$Res, UserProfile>;
  @useResult
  $Res call(
      {String id,
      String email,
      String authMethod,
      bool syncEnabled,
      String? displayName,
      DateTime? lastSyncAt,
      String? localLibraryPath});
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res, $Val extends UserProfile>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? authMethod = null,
    Object? syncEnabled = null,
    Object? displayName = freezed,
    Object? lastSyncAt = freezed,
    Object? localLibraryPath = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      authMethod: null == authMethod
          ? _value.authMethod
          : authMethod // ignore: cast_nullable_to_non_nullable
              as String,
      syncEnabled: null == syncEnabled
          ? _value.syncEnabled
          : syncEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastSyncAt: freezed == lastSyncAt
          ? _value.lastSyncAt
          : lastSyncAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      localLibraryPath: freezed == localLibraryPath
          ? _value.localLibraryPath
          : localLibraryPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserProfileImplCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$UserProfileImplCopyWith(
          _$UserProfileImpl value, $Res Function(_$UserProfileImpl) then) =
      __$$UserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String email,
      String authMethod,
      bool syncEnabled,
      String? displayName,
      DateTime? lastSyncAt,
      String? localLibraryPath});
}

/// @nodoc
class __$$UserProfileImplCopyWithImpl<$Res>
    extends _$UserProfileCopyWithImpl<$Res, _$UserProfileImpl>
    implements _$$UserProfileImplCopyWith<$Res> {
  __$$UserProfileImplCopyWithImpl(
      _$UserProfileImpl _value, $Res Function(_$UserProfileImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? authMethod = null,
    Object? syncEnabled = null,
    Object? displayName = freezed,
    Object? lastSyncAt = freezed,
    Object? localLibraryPath = freezed,
  }) {
    return _then(_$UserProfileImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      authMethod: null == authMethod
          ? _value.authMethod
          : authMethod // ignore: cast_nullable_to_non_nullable
              as String,
      syncEnabled: null == syncEnabled
          ? _value.syncEnabled
          : syncEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastSyncAt: freezed == lastSyncAt
          ? _value.lastSyncAt
          : lastSyncAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      localLibraryPath: freezed == localLibraryPath
          ? _value.localLibraryPath
          : localLibraryPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileImpl implements _UserProfile {
  const _$UserProfileImpl(
      {required this.id,
      required this.email,
      this.authMethod = '',
      this.syncEnabled = false,
      this.displayName,
      this.lastSyncAt,
      this.localLibraryPath});

  factory _$UserProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileImplFromJson(json);

  @override
  final String id;
  @override
  final String email;
// Default values allow you to avoid null checks in UI
  @override
  @JsonKey()
  final String authMethod;
  @override
  @JsonKey()
  final bool syncEnabled;
  @override
  final String? displayName;
  @override
  final DateTime? lastSyncAt;
  @override
  final String? localLibraryPath;

  @override
  String toString() {
    return 'UserProfile(id: $id, email: $email, authMethod: $authMethod, syncEnabled: $syncEnabled, displayName: $displayName, lastSyncAt: $lastSyncAt, localLibraryPath: $localLibraryPath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.authMethod, authMethod) ||
                other.authMethod == authMethod) &&
            (identical(other.syncEnabled, syncEnabled) ||
                other.syncEnabled == syncEnabled) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.lastSyncAt, lastSyncAt) ||
                other.lastSyncAt == lastSyncAt) &&
            (identical(other.localLibraryPath, localLibraryPath) ||
                other.localLibraryPath == localLibraryPath));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, email, authMethod,
      syncEnabled, displayName, lastSyncAt, localLibraryPath);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      __$$UserProfileImplCopyWithImpl<_$UserProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileImplToJson(
      this,
    );
  }
}

abstract class _UserProfile implements UserProfile {
  const factory _UserProfile(
      {required final String id,
      required final String email,
      final String authMethod,
      final bool syncEnabled,
      final String? displayName,
      final DateTime? lastSyncAt,
      final String? localLibraryPath}) = _$UserProfileImpl;

  factory _UserProfile.fromJson(Map<String, dynamic> json) =
      _$UserProfileImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override // Default values allow you to avoid null checks in UI
  String get authMethod;
  @override
  bool get syncEnabled;
  @override
  String? get displayName;
  @override
  DateTime? get lastSyncAt;
  @override
  String? get localLibraryPath;
  @override
  @JsonKey(ignore: true)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
