// lib/domain/entities/user_profile.dart
import 'dart:convert';

class UserProfile {
  UserProfile({
    required this.id,
    required this.email,
    required this.authMethod,
    required this.syncEnabled,
    this.displayName,
    this.lastSyncAt,
    this.localLibraryPath,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      displayName: map['displayName']?.toString(),
      authMethod: map['authMethod']?.toString() ?? '',
      syncEnabled: map['syncEnabled'] == true,
      lastSyncAt: map['lastSyncAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['lastSyncAt'] is int
                  ? map['lastSyncAt'] as int
                  : int.parse(map['lastSyncAt'].toString()),
            )
          : null,
      localLibraryPath: map['localLibraryPath']?.toString(),
    );
  }

  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(json.decode(source) as Map<String, dynamic>);
  final String id;
  final String email;
  final String? displayName;
  final String authMethod;
  final bool syncEnabled;
  final DateTime? lastSyncAt;
  final String? localLibraryPath;

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? authMethod,
    bool? syncEnabled,
    DateTime? lastSyncAt,
    String? localLibraryPath,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      authMethod: authMethod ?? this.authMethod,
      syncEnabled: syncEnabled ?? this.syncEnabled,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      localLibraryPath: localLibraryPath ?? this.localLibraryPath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'authMethod': authMethod,
      'syncEnabled': syncEnabled,
      'lastSyncAt': lastSyncAt?.millisecondsSinceEpoch,
      'localLibraryPath': localLibraryPath,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'UserProfile(id: $id, email: $email, displayName: $displayName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
