import 'package:flutbook/core/services/json_storage_service.dart';

class SettingsLocalDatasource {
  SettingsLocalDatasource(this._jsonStorage);
  final JsonStorageService _jsonStorage;

  Future<Map<String, dynamic>> getSettings() async {
    return await _jsonStorage.readSettings() ?? {};
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _jsonStorage.writeSettings(settings);
  }
}
