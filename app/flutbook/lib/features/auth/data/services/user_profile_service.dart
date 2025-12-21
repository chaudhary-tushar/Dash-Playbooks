// lib/features/auth/data/services/user_profile_service.dart

import 'package:flutbook/core/services/database_service.dart';
import 'package:flutbook/features/auth/data/datasources/user_profile_datasource.dart';
import 'package:flutbook/features/auth/data/models/user_profile_model.dart';
import 'package:flutbook/features/auth/domain/entities/user_profile.dart';

/// UserProfileService handles user profile operations and static data generation.
///
/// This service provides:
/// - Static data generation for user profiles
/// - User profile management
/// - Integration with ISAR database via UserProfileDatasource
class UserProfileService {
  /// Create a new UserProfileService.
  ///
  /// [databaseService] - The database service providing ISAR instance
  UserProfileService({required DatabaseService databaseService})
    : _datasource = UserProfileDatasource(databaseService: databaseService);

  final UserProfileDatasource _datasource;

  /// Generates static data for a new user profile.
  ///
  /// [userId] - The user ID from authentication
  /// [email] - The user email
  /// [authMethod] - The authentication method (email_password, google_oauth, anonymous, development)
  /// [displayName] - Optional display name
  /// Returns the generated UserProfileModel
  Future<UserProfileModel> generateStaticUserProfileData({
    required String userId,
    required String email,
    required String authMethod,
    String? displayName,
  }) async {
    // Create base user profile
    final userProfile = UserProfileModel(
      internalId: userId,
      email: email,
      displayName:
          displayName ?? _generateDefaultDisplayName(email, authMethod),
      authMethod: authMethod,
      syncEnabled: _shouldEnableSync(authMethod),
    );

    return userProfile;
  }

  /// Generates static data and saves it to the database.
  ///
  /// [userId] - The user ID from authentication
  /// [email] - The user email
  /// [authMethod] - The authentication method
  /// [displayName] - Optional display name
  /// Returns the saved UserProfileModel
  Future<UserProfileModel> generateAndSaveUserProfile({
    required String userId,
    required String email,
    required String authMethod,
    String? displayName,
  }) async {
    final profile = await generateStaticUserProfileData(
      userId: userId,
      email: email,
      authMethod: authMethod,
      displayName: displayName,
    );

    // Save to database
    return _datasource.saveUserProfile(profile);
  }

  /// Updates user profile during authentication.
  ///
  /// [userProfile] - The domain UserProfile from authentication
  /// Returns the updated UserProfileModel
  Future<UserProfileModel> updateUserProfileDuringAuth(
    UserProfile userProfile,
  ) async {
    // Convert domain model to data model
    final model = UserProfileModel.fromDomain(userProfile);

    // Save or update in database
    return _datasource.saveUserProfile(model);
  }

  /// Gets the current user profile from the database.
  ///
  /// Returns UserProfile if found, null otherwise
  Future<UserProfile?> getCurrentUserProfile() async {
    return _datasource.getCurrentUserProfileAsDomain();
  }

  /// Checks if any user profile exists in the database.
  ///
  /// Returns true if at least one user profile exists
  Future<bool> hasUserProfiles() async {
    return _datasource.hasUserProfiles();
  }

  /// Deletes all user profiles from the database.
  ///
  /// Returns true if deletion was successful
  Future<bool> deleteAllUserProfiles() async {
    return _datasource.deleteAllUserProfiles();
  }

  /// Generates a default display name based on email and auth method.
  String _generateDefaultDisplayName(String email, String authMethod) {
    if (authMethod == 'anonymous') {
      return 'Anonymous User';
    }

    if (authMethod == 'development') {
      return 'Development User';
    }

    // Extract name from email for email-based authentication
    final emailParts = email.split('@');
    if (emailParts.isNotEmpty) {
      final localPart = emailParts[0];
      // Replace dots and other characters with spaces for better display
      return localPart.replaceAll('.', ' ').replaceAll('_', ' ');
    }

    return 'User';
  }

  /// Determines if sync should be enabled based on authentication method.
  bool _shouldEnableSync(String authMethod) {
    // Anonymous and development users should not sync by default
    return authMethod != 'anonymous' && authMethod != 'development';
  }

  /// Updates the local library path for the current user.
  ///
  /// [path] - The local library path
  /// Returns true if update was successful
  Future<bool> updateLocalLibraryPath(String path) async {
    final currentProfile = await _datasource.getCurrentUserProfile();
    if (currentProfile == null) {
      return false;
    }

    // Create a new UserProfileModel with updated path
    final updatedProfile = UserProfileModel(
      internalId: currentProfile.internalId,
      email: currentProfile.email,
      displayName: currentProfile.displayName,
      authMethod: currentProfile.authMethod,
      syncEnabled: currentProfile.syncEnabled,
      lastSyncAt: currentProfile.lastSyncAt,
      localLibraryPath: path,
    );

    await _datasource.saveUserProfile(updatedProfile);
    return true;
  }

  /// Updates the sync enabled status for the current user.
  ///
  /// [enabled] - Whether sync should be enabled
  /// Returns true if update was successful
  Future<bool> updateSyncEnabled(bool enabled) async {
    final currentProfile = await _datasource.getCurrentUserProfile();
    if (currentProfile == null) {
      return false;
    }

    // Create a new UserProfileModel with updated sync status
    final updatedProfile = UserProfileModel(
      internalId: currentProfile.internalId,
      email: currentProfile.email,
      displayName: currentProfile.displayName,
      authMethod: currentProfile.authMethod,
      syncEnabled: enabled,
      lastSyncAt: currentProfile.lastSyncAt,
      localLibraryPath: currentProfile.localLibraryPath,
    );

    await _datasource.saveUserProfile(updatedProfile);
    return true;
  }

  /// Updates the last sync timestamp for the current user.
  ///
  /// Returns true if update was successful
  Future<bool> updateLastSyncTimestamp() async {
    final currentProfile = await _datasource.getCurrentUserProfile();
    if (currentProfile == null) {
      return false;
    }

    // Create a new UserProfileModel with updated timestamp
    final updatedProfile = UserProfileModel(
      internalId: currentProfile.internalId,
      email: currentProfile.email,
      displayName: currentProfile.displayName,
      authMethod: currentProfile.authMethod,
      syncEnabled: currentProfile.syncEnabled,
      lastSyncAt: DateTime.now(),
      localLibraryPath: currentProfile.localLibraryPath,
    );

    await _datasource.saveUserProfile(updatedProfile);
    return true;
  }
}
