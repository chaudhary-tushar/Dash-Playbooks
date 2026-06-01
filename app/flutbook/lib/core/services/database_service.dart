import 'package:flutbook/features/auth/data/models/user_profile_model.dart';
import 'package:flutbook/features/library/data/models/audiobook_model.dart';
import 'package:flutbook/features/library/data/models/library_model.dart';
import 'package:flutbook/features/player/data/models/audio_effect_model.dart';
import 'package:flutbook/features/player/data/models/bookmark_model.dart';
import 'package:flutbook/features/player/data/models/playback_history_model.dart';
import 'package:flutbook/features/player/data/models/playback_session_model.dart';
import 'package:flutbook/features/player/data/models/queue_model.dart';
import 'package:flutbook/features/sync/data/models/queue_item_model.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  late Isar _isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        AudiobookModelSchema,
        AudioEffectModelSchema,
        BookmarkModelSchema,
        LibraryModelSchema,
        PlaybackHistoryModelSchema,
        PlaybackSessionModelSchema,
        QueueItemModelSchema,
        QueueModelSchema,
        UserProfileModelSchema,
      ],
      directory: dir.path,
    );
  }

  Future<void> close() async {
    await _isar.close();
  }

  Isar get isar => _isar;
  bool get isOpen => _isar.isOpen;
}
