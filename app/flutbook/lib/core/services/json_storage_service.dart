// lib/data/datasources/local/json_storage.dart
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles JSON storage for settings as required by specification (FR-008)
class JsonStorage {
  static const String _settingsFileName = 'app_settings.json';
  static const String _userPreferencesKey = 'user_preferences';

  /// Gets the directory path for storing settings files
  static Future<String> _getSettingsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final settingsDir = Directory('${directory.path}/settings');
    if (!await settingsDir.exists()) {
      await settingsDir.create(recursive: true);
    }
    return settingsDir.path;
  }

  /// Reads settings from JSON file
  Future<Map<String, dynamic>?> readSettings() async {
    try {
      final dirPath = await _getSettingsDirectory();
      final file = File('$dirPath/$_settingsFileName');

      if (await file.exists()) {
        final contents = await file.readAsString();
        final jsonData = jsonDecode(contents) as Map<String, dynamic>;
        return jsonData;
      }

      return null; // Return null if file doesn't exist
    } catch (e) {
      print('Error reading settings: $e');
      return null;
    }
  }

  /// Writes settings to JSON file
  Future<bool> writeSettings(Map<String, dynamic> settings) async {
    try {
      final dirPath = await _getSettingsDirectory();
      final file = File('$dirPath/$_settingsFileName');

      final jsonString = jsonEncode(settings);
      await file.writeAsString(jsonString);

      return true;
    } catch (e) {
      print('Error writing settings: $e');
      return false;
    }
  }

  /// Gets a specific setting value by key
  Future<dynamic> getSetting(String key) async {
    final settings = await readSettings();
    return settings?[key];
  }

  /// Sets a specific setting value by key
  Future<bool> setSetting(String key, dynamic value) async {
    final settings = await readSettings() ?? <String, dynamic>{};
    settings[key] = value;
    return writeSettings(settings);
  }

  /// Removes a specific setting
  Future<bool> removeSetting(String key) async {
    final settings = await readSettings();
    if (settings != null && settings.containsKey(key)) {
      settings.remove(key);
      return writeSettings(settings);
    }
    return true; // Nothing to remove, so considered successful
  }

  /// Clears all settings (for testing or user request)
  Future<bool> clearAllSettings() async {
    try {
      final dirPath = await _getSettingsDirectory();
      final file = File('$dirPath/$_settingsFileName');

      if (await file.exists()) {
        await file.delete();
      }

      return true;
    } catch (e) {
      print('Error clearing settings: $e');
      return false;
    }
  }

  /// Reads user preferences using shared_preferences as backup/redundancy
  Future<Map<String, dynamic>?> readUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefsString = prefs.getString(_userPreferencesKey);

      if (prefsString != null) {
        return jsonDecode(prefsString) as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      print('Error reading user preferences: $e');
      return null;
    }
  }

  /// Writes user preferences using shared_preferences
  Future<bool> writeUserPreferences(Map<String, dynamic> preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefsString = jsonEncode(preferences);
      return await prefs.setString(_userPreferencesKey, prefsString);
    } catch (e) {
      print('Error writing user preferences: $e');
      return false;
    }
  }

  /// Gets a specific user preference
  Future<dynamic> getUserPreference(String key) async {
    final prefs = await readUserPreferences();
    return prefs?[key];
  }

  /// Sets a specific user preference
  Future<bool> setUserPreference(String key, dynamic value) async {
    final prefs = await readUserPreferences() ?? <String, dynamic>{};
    prefs[key] = value;
    return writeUserPreferences(prefs);
  }
}
