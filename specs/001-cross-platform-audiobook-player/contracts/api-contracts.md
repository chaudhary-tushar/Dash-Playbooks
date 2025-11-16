# API Contracts: Cross-Platform Audiobook Player

## Repository Interfaces

### AudiobookRepository
```dart
abstract class AudiobookRepository {
  /// Retrieves all audiobooks in the user's library using Isar database
  Future<List<Audiobook>> getAllAudiobooks();

  /// Gets a specific audiobook by ID using Isar database
  Future<Audiobook?> getAudiobookById(String id);

  /// Scans a directory and saves audiobooks to Isar database with proper schema
  Future<List<Audiobook>> scanDirectory(String directoryPath);

  /// Updates an audiobook record in Isar database with proper indexing
  Future<void> updateAudiobook(Audiobook audiobook);

  /// Deletes an audiobook record (does not delete file) from Isar database
  Future<void> deleteAudiobook(String id);

  /// Searches audiobooks by title, author, etc. using Isar indexed queries
  Future<List<Audiobook>> searchAudiobooks(String query);

  /// Filters audiobooks by status (in_progress, completed, etc.) using Isar indexed queries
  Future<List<Audiobook>> filterAudiobooks(AudiobookFilter filter);

  /// Finds audiobooks by specific criteria using Isar compound indexes
  Future<List<Audiobook>> findAudiobooks({String? author, bool? completed, int? limit});
}
```

### PlaybackRepository
```dart
abstract class PlaybackRepository {
  /// Gets the current playback session for an audiobook
  Future<PlaybackSession?> getPlaybackSession(String audiobookId);
  
  /// Updates the current playback position
  Future<void> updatePlaybackPosition(String audiobookId, Duration position);
  
  /// Saves playback session state
  Future<void> savePlaybackSession(PlaybackSession session);
  
  /// Gets all playback sessions
  Future<List<PlaybackSession>> getAllPlaybackSessions();
  
  /// Marks an audiobook as completed
  Future<void> markAudiobookAsCompleted(String audiobookId);
  
  /// Updates playback speed preference
  Future<void> updatePlaybackSpeed(String audiobookId, double speed);
}
```

### UserRepository
```dart
abstract class UserRepository {
  /// Attempts to authenticate user with email and password
  Future<AuthResult> signInWithEmailAndPassword(String email, String password);
  
  /// Attempts to authenticate user with Google
  Future<AuthResult> signInWithGoogle();
  
  /// Creates a new user account
  Future<AuthResult> signUpWithEmailAndPassword(String email, String password);
  
  /// Signs out the current user
  Future<void> signOut();
  
  /// Gets the current authenticated user
  Future<UserProfile?> getCurrentUser();
  
  /// Gets sync status
  Future<SyncStatus> getSyncStatus();
  
  /// Syncs local data with remote
  Future<SyncResult> syncWithRemote();
  
  /// Gets user settings
  Future<UserSettings> getUserSettings();
  
  /// Updates user settings
  Future<void> updateUserSettings(UserSettings settings);
}
```

## Use Case Interfaces

### ScanLibraryUseCase
```dart
abstract class ScanLibraryUseCase {
  /// Scans a directory and updates the local library
  Future<ScanResult> execute(String directoryPath);
}
```

### SyncLibraryUseCase
```dart
abstract class SyncLibraryUseCase {
  /// Syncs local library with remote storage
  Future<SyncResult> execute();
  
  /// Handles conflicts when local and remote data differ
  Future<ConflictResolutionResult> resolveConflicts(List<SyncConflict> conflicts);
}
```

### GetPlaybackStateUseCase
```dart
abstract class GetPlaybackStateUseCase {
  /// Gets the current playback state for an audiobook
  Future<PlaybackState> execute(String audiobookId);
  
  /// Updates playback position
  Future<void> updatePosition(String audiobookId, Duration newPosition);
}
```

## Data Source Interfaces

### LocalDataSource
```dart
abstract class LocalDataSource {
  /// Saves audiobook metadata to Isar database with proper schema and indexing
  /// Handles large files (>10GB) with appropriate memory management
  /// Throws specific exceptions for corrupted files or insufficient storage
  Future<void> saveAudiobooks(List<Audiobook> audiobooks);

  /// Gets audiobooks from Isar database using indexed queries for performance
  /// Handles cases where files may have been moved/deleted since last scan
  Future<List<Audiobook>> getAudiobooks();

  /// Gets a single audiobook from Isar database by ID
  Future<Audiobook?> getAudiobookById(String id);

  /// Saves playback session to Isar database with proper indexing
  Future<void> savePlaybackSession(PlaybackSession session);

  /// Gets playback session from Isar database
  Future<PlaybackSession?> getPlaybackSession(String audiobookId);

  /// Searches audiobooks using Isar's full-text search capabilities
  /// Returns appropriate results even with missing or corrupted metadata
  Future<List<Audiobook>> searchAudiobooks(String query);

  /// Filters audiobooks using Isar's indexed fields for efficient queries
  /// Handles filtering with incomplete or missing metadata
  Future<List<Audiobook>> filterAudiobooks(AudiobookFilter filter);

  /// Gets all settings from JSON storage
  Future<Map<String, dynamic>> getSettings();

  /// Saves settings to JSON storage
  Future<void> saveSettings(Map<String, dynamic> settings);

  /// Initializes Isar database with proper schema including all indexes
  /// Sets up proper error handling for database access issues
  Future<void> initializeDatabase();

  /// Performs database migrations if needed
  /// Handles migration failures gracefully
  Future<void> migrateDatabase();

  /// Clears Isar database (for testing or user request)
  Future<void> clearDatabase();

  /// Performs cleanup and closes Isar database connection
  Future<void> closeDatabase();

  /// Checks if audio file still exists and is accessible
  /// Used to handle cases where files are moved/deleted after scanning
  Future<bool> isFileAccessible(String filePath);
}
```

### RemoteDataSource
```dart
abstract class RemoteDataSource {
  /// Uploads audiobook metadata to remote storage
  Future<void> uploadAudiobookMetadata(Audiobook audiobook);
  
  /// Gets audiobook metadata from remote storage
  Future<List<Audiobook>> getAudiobookMetadata();
  
  /// Uploads playback session to remote storage
  Future<void> uploadPlaybackSession(PlaybackSession session);
  
  /// Gets playback sessions from remote storage
  Future<List<PlaybackSession>> getPlaybackSessions();
  
  /// Syncs all user data with remote
  Future<SyncResult> syncAll();
}
```

## Event Contracts

### PlaybackEvents
```dart
abstract class PlaybackEvents {
  /// Emitted when playback starts
  static const String PLAYBACK_STARTED = 'playback_started';
  
  /// Emitted when playback pauses
  static const String PLAYBACK_PAUSED = 'playback_paused';
  
  /// Emitted when playback position changes
  static const String POSITION_CHANGED = 'position_changed';
  
  /// Emitted when a track ends
  static const String TRACK_ENDED = 'track_ended';
  
  /// Emitted when an error occurs
  static const String PLAYBACK_ERROR = 'playback_error';
}
```

### SyncEvents
```dart
abstract class SyncEvents {
  /// Emitted when sync starts
  static const String SYNC_STARTED = 'sync_started';
  
  /// Emitted when sync completes successfully
  static const String SYNC_COMPLETED = 'sync_completed';
  
  /// Emitted when sync fails
  static const String SYNC_FAILED = 'sync_failed';
  
  /// Emitted when conflicts are detected
  static const String CONFLICT_DETECTED = 'conflict_detected';
}
```