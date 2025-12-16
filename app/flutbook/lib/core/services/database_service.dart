// lib/core/services/database_service.dart
import 'package:flutbook/features/auth/data/models/user_profile_model.dart'; // formerly UserProfileModel
// Import ALL feature models here so Isar knows about them
import 'package:flutbook/features/library/data/models/audiobook_model.dart';
import 'package:flutbook/features/player/data/models/playback_session_model.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  late Isar _isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open([
      AudiobookModelSchema,
      PlaybackSessionModelSchema,
      UserProfileModelSchema, // Renamed from UserProfileModel
    ], directory: dir.path);
  }

  /// Closes the Isar database connection
  Future<void> close() async {
    await _isar.close();
  }

  Isar get isar => _isar;
}
