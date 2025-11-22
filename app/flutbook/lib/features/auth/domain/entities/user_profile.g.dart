// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      authMethod: json['authMethod'] as String? ?? '',
      syncEnabled: json['syncEnabled'] as bool? ?? false,
      displayName: json['displayName'] as String?,
      lastSyncAt: json['lastSyncAt'] == null
          ? null
          : DateTime.parse(json['lastSyncAt'] as String),
      localLibraryPath: json['localLibraryPath'] as String?,
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'authMethod': instance.authMethod,
      'syncEnabled': instance.syncEnabled,
      'displayName': instance.displayName,
      'lastSyncAt': instance.lastSyncAt?.toIso8601String(),
      'localLibraryPath': instance.localLibraryPath,
    };
