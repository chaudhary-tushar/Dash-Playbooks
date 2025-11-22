// lib/features/auth/data/models/user_profile_model.dart

import 'package:flutbook/features/auth/domain/entities/user_profile.dart' as domain;
import 'package:isar_community/isar.dart';

part 'user_profile_model.g.dart';

@collection
class UserProfileModel {
  UserProfileModel({
    required this.email,
    required this.authMethod,
    required this.syncEnabled,
    this.id,
    this.internalId,
    this.displayName,
    this.lastSyncAt,
    this.localLibraryPath,
  });

  // Convert from domain entity
  factory UserProfileModel.fromDomain(domain.UserProfile profile) {
    return UserProfileModel(
      internalId: profile.id,
      email: profile.email,
      displayName: profile.displayName,
      authMethod: profile.authMethod,
      syncEnabled: profile.syncEnabled,
      lastSyncAt: profile.lastSyncAt,
      localLibraryPath: profile.localLibraryPath,
    );
  }
  Id? id = Isar.autoIncrement;

  String? internalId; // Maps to domain user.id
  String email;
  String? displayName;
  String authMethod; // email_password, google_oauth, etc.
  bool syncEnabled;
  DateTime? lastSyncAt;
  String? localLibraryPath;

  // Convert to domain entity
  domain.UserProfile toDomain() {
    return domain.UserProfile(
      id: internalId ?? '', // fallback to empty string if not set yet
      email: email,
      displayName: displayName,
      authMethod: authMethod,
      syncEnabled: syncEnabled,
      lastSyncAt: lastSyncAt,
      localLibraryPath: localLibraryPath,
    );
  }
}
