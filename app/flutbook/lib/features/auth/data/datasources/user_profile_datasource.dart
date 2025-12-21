// lib/features/auth/data/datasources/user_profile_datasource.dart

import 'package:flutbook/core/services/database_service.dart';
import 'package:flutbook/features/auth/data/models/user_profile_model.dart';
import 'package:flutbook/features/auth/domain/entities/user_profile.dart';
import 'package:isar_community/isar.dart';

/// UserProfile datasource for ISAR database operations.
///
/// This datasource handles all UserProfileModel operations with the ISAR database,
/// including CRUD operations and user profile management.
class UserProfileDatasource {
  /// Create a new UserProfileDatasource.
  ///
  /// [databaseService] - The database service providing ISAR instance
  UserProfileDatasource({required DatabaseService databaseService})
    : _isar = databaseService.isar;

  final Isar _isar;

  /// Saves or updates a user profile in the ISAR database.
  ///
  /// [profile] - The UserProfileModel to save
  /// Returns the saved UserProfileModel
  Future<UserProfileModel> saveUserProfile(UserProfileModel profile) async {
    // Use put to save or update the profile
    await _isar.writeTxn(() async {
      await _isar.userProfileModels.put(profile);
    });

    // Return the saved profile with updated ID
    return profile;
  }

  /// Gets a user profile by internal ID from the ISAR database.
  ///
  /// [internalId] - The internal user ID to search for
  /// Returns UserProfileModel if found, null otherwise
  Future<UserProfileModel?> getUserProfileByInternalId(
    String internalId,
  ) async {
    return _isar.userProfileModels
        .filter()
        .internalIdEqualTo(internalId)
        .findFirst();
  }

  /// Gets a user profile by email from the ISAR database.
  ///
  /// [email] - The email to search for
  /// Returns UserProfileModel if found, null otherwise
  Future<UserProfileModel?> getUserProfileByEmail(String email) async {
    return _isar.userProfileModels.filter().emailEqualTo(email).findFirst();
  }

  /// Gets the currently logged-in user profile from the ISAR database.
  ///
  /// Returns UserProfileModel if found, null otherwise
  Future<UserProfileModel?> getCurrentUserProfile() async {
    // Get the most recently added user profile (assuming it's the current user)
    return _isar.userProfileModels.where().sortByInternalIdDesc().findFirst();
  }

  /// Gets all user profiles from the ISAR database.
  ///
  /// Returns list of UserProfileModel objects
  Future<List<UserProfileModel>> getAllUserProfiles() async {
    return _isar.userProfileModels.where().findAll();
  }

  /// Deletes a user profile from the ISAR database.
  ///
  /// [internalId] - The internal user ID to delete
  /// Returns true if deletion was successful
  Future<bool> deleteUserProfile(String internalId) async {
    final result = await _isar.writeTxn(() async {
      return _isar.userProfileModels
          .filter()
          .internalIdEqualTo(internalId)
          .deleteFirst();
    });

    return result;
  }

  /// Deletes all user profiles from the ISAR database.
  ///
  /// Returns true if deletion was successful
  Future<bool> deleteAllUserProfiles() async {
    await _isar.writeTxn(() async {
      await _isar.userProfileModels.clear();
    });

    return true;
  }

  /// Checks if any user profile exists in the ISAR database.
  ///
  /// Returns true if at least one user profile exists
  Future<bool> hasUserProfiles() async {
    final count = await _isar.userProfileModels.count();
    return count > 0;
  }

  /// Converts a domain UserProfile to UserProfileModel and saves it.
  ///
  /// [profile] - The domain UserProfile to save
  /// Returns the saved UserProfileModel
  Future<UserProfileModel> saveDomainUserProfile(UserProfile profile) async {
    final model = UserProfileModel.fromDomain(profile);
    return saveUserProfile(model);
  }

  /// Gets the current user profile as a domain entity.
  ///
  /// Returns UserProfile if found, null otherwise
  Future<UserProfile?> getCurrentUserProfileAsDomain() async {
    final model = await getCurrentUserProfile();
    return model?.toDomain();
  }
}
