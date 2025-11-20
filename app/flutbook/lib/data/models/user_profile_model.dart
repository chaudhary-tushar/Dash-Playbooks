// lib/data/models/user_profile_model.dart
import 'package:isar/isar.dart';

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
  Id? id = Isar.autoIncrement; // This will be generated automatically

  String? internalId; // Original user_profile.id
  String email;
  String? displayName;
  String authMethod; // email_password, google_oauth, etc.
  bool syncEnabled;
  DateTime? lastSyncAt;
  String? localLibraryPath;
}
