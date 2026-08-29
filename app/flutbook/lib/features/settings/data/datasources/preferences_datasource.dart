/// Preferences datasource backed by the single JSON settings store.
///
/// Consolidates user preferences and sync-status tracking onto [JsonStorage]
/// so there is one authoritative, persistent settings mechanism instead of an
/// in-memory no-op stub. Keys are namespaced to avoid collisions with any
/// other settings consumer.
library;

import 'package:flutbook/core/services/json_storage_service.dart';

class PreferencesDatasource {
  PreferencesDatasource(this._jsonStorage);

  final JsonStorage _jsonStorage;

  static const String _pendingSyncKey = 'has_pending_sync_changes';
  static const String _lastSyncTimeKey = 'last_sync_time';
  static const String _lastSyncSuccessfulKey = 'last_sync_successful';
  static const String _userPreferencesKey = 'user_preferences';

  Future<void> saveUserPreferences(dynamic user) async {
    // Kept for interface compatibility; preferences are persisted through
    // getUserSettings()/saveUserSettings().
    await _jsonStorage.writeUserPreferences(
      user is Map<String, dynamic> ? user : <String, dynamic>{},
    );
  }

  Future<bool> hasPendingSyncChanges() async {
    final value = await _jsonStorage.getSetting(_pendingSyncKey);
    return value is bool && value;
  }

  Future<DateTime?> getLastSyncTime() async {
    final value = await _jsonStorage.getSetting(_lastSyncTimeKey);
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  Future<bool> getLastSyncSuccessful() async {
    final value = await _jsonStorage.getSetting(_lastSyncSuccessfulKey);
    return value is bool && value;
  }

  Future<void> setLastSyncTime(DateTime time) async {
    await _jsonStorage.setSetting(_lastSyncTimeKey, time.toIso8601String());
  }

  Future<void> setLastSyncSuccessful(bool value) async {
    await _jsonStorage.setSetting(_lastSyncSuccessfulKey, value);
  }

  Future<Map<String, dynamic>> getUserSettings() async {
    final prefs = await _jsonStorage.readUserPreferences();
    return prefs ?? <String, dynamic>{};
  }

  Future<void> saveUserSettings(Map<String, dynamic> settings) async {
    await _jsonStorage.writeUserPreferences(settings);
  }
}
