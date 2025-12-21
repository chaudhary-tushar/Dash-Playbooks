hrrPlayback Refactor Plan

Overview
This document outlines a comprehensive plan to refactor the playback system to address the critical error: "Playback local datasource not initialized" that occurs when clicking play buttons on the library screen.

Root Cause Analysis
Based on the error logs:
1. The playback local datasource is not initialized when the playback provider is created
2. The provider throws an exception during initialization: "Exception: Playback local datasource not initialized"
3. This causes a ProviderException which cascades through the widget tree
4. The error occurs in the playbackRepositoryProvider during the build phase of PlaybackNotifier

Refactor Goals
- Ensure proper initialization of all playback-related datasources
- Fix provider dependencies to prevent initialization order issues
- Implement proper error handling for uninitialized datasources
- Stabilize the playback provider lifecycle

Phase 1: Datasource Initialization Fix (Day 1)
Tasks
1. **Fix Playback Local Datasource Initialization**
   - Review the PlaybackLocalDatasource initialization in lib/features/player/data/datasources/playback_local_ds.dart
   - Ensure the Isar database instance is properly passed during initialization
   - Add null checks and proper error handling

2. **Update Provider Dependencies**
   - Review the playbackLocalDatasourceProvider in lib/core/provider/providers.dart
   - Ensure it depends on the databaseServiceProvider and waits for proper initialization
   - Add async initialization if needed

3. **Implement Proper Error Handling**
   - Create a fallback mechanism when datasources are not initialized
   - Add early return logic in repository methods when datasources are null
   - Implement graceful degradation when playback features are unavailable

Acceptance Criteria
- Playback local datasource initializes without errors
- No "not initialized" exceptions during provider creation
- Proper error handling when dependencies are unavailable

Phase 2: Repository Layer Refactor (Day 2)
Tasks
1. **Fix Playback Repository Implementation**
   - Review PlaybackRepositoryImpl in lib/features/player/data/repositories/playback_repository_impl.dart
   - Add null safety checks for all datasource dependencies
   - Implement proper initialization checks before using datasources

2. **Update Repository Provider**
   - Review the playbackRepositoryProvider in lib/core/provider/providers.dart
   - Ensure it properly handles initialization failures
   - Add async provider if needed for proper initialization sequence

3. **Add Initialization Validation**
   - Implement a method in the repository to validate all dependencies are initialized
   - Add this validation to the repository's initialization process
   - Return appropriate errors when dependencies are not ready

Acceptance Criteria
- Repository properly handles uninitialized datasources
- No exceptions thrown during repository initialization
- Clear error messages when dependencies are not ready

Phase 3: Provider Dependency Chain Fix (Day 3)
Tasks
1. **Fix Provider Initialization Order**
   - Review all playback-related providers in lib/core/provider/providers.dart
   - Ensure database service initializes before any playback providers
   - Implement proper async initialization for providers that depend on database

2. **Update Playback Provider Implementation**
   - Review PlaybackNotifier in lib/features/player/presentation/providers/playback_provider.dart
   - Add proper error handling when repository is in error state
   - Implement fallback states when playback is unavailable

3. **Add Provider State Management**
   - Implement proper loading/error states for playback providers
   - Add retry mechanisms for failed initializations
   - Create clear error states that UI can handle gracefully

Acceptance Criteria
- Provider initialization order is properly managed
- No cascading failures when one provider fails
- Clear state management for playback functionality

Phase 4: UI Integration and Error Handling (Day 4)
Tasks
1. **Update Playback Screen Error Handling**
   - Review PlaybackScreen in lib/features/player/presentation/views/playback_screen.dart
   - Add proper error handling when playback provider is in error state
   - Implement fallback UI when playback is unavailable

2. **Library Screen Playback Button Fix**
   - Review how play buttons trigger playback in library screens
   - Add validation before attempting to access playback functionality
   - Implement appropriate error messaging when playback is unavailable

3. **Add User-Facing Error Messages**
   - Create user-friendly error messages for playback initialization failures
   - Implement retry mechanisms in the UI
   - Add notifications for users when playback features are unavailable

Acceptance Criteria
- Library screen play buttons work without throwing exceptions
- Playback screen handles error states gracefully
- Users receive appropriate feedback when playback is unavailable

Implementation Steps

Step 1: Update Playback Local Datasource
```dart
class PlaybackLocalDatasource {
  PlaybackLocalDatasource(this._isar);

  final Isar _isar;

  bool get isInitialized => _isar.isOpen;

  // Add validation method
  void validateInitialization() {
    if (!isInitialized) {
      throw Exception('Playback local datasource not initialized');
    }
  }

  // Wrap all methods with validation
  Future<void> savePlaybackSession(PlaybackSessionModel sessionModel) async {
    validateInitialization();
    // ... existing implementation
  }
}
```

Step 2: Update Repository with Null Safety
```dart
class PlaybackRepositoryImpl implements PlaybackRepository {
  PlaybackRepositoryImpl({
    required this.localDatasource,
    required this.remoteDatasource,
  });

  final PlaybackLocalDatasource localDatasource;
  final PlaybackRemoteDatasource remoteDatasource;

  bool get isInitialized => localDatasource.isInitialized;

  @override
  Future<void> savePlaybackSession(PlaybackSession session) async {
    if (!isInitialized) {
      throw Exception('Playback repository not initialized');
    }
    // ... existing implementation
  }
}
```

Step 3: Update Provider Dependencies
```dart
final playbackLocalDatasourceProvider = Provider<PlaybackLocalDatasource>((ref) {
  final isar = ref.watch(databaseServiceProvider).isar;
  return PlaybackLocalDatasource(isar);
});

final playbackRepositoryProvider = Provider<PlaybackRepository>((ref) {
  final localDatasource = ref.watch(playbackLocalDatasourceProvider);
  final remoteDatasource = ref.watch(playbackRemoteDatasourceProvider);
  return PlaybackRepositoryImpl(
    localDatasource: localDatasource,
    remoteDatasource: remoteDatasource,
  );
});
```

Step 4: Update UI Error Handling
- Add try-catch blocks around playback operations
- Implement proper loading/error states in UI
- Add user-friendly error messages

Testing Plan
1. Unit tests for datasource initialization validation
2. Widget tests for playback screen error states
3. Integration tests for the complete playback initialization flow
4. Error handling tests for all failure scenarios

Success Metrics
- No "Playback local datasource not initialized" errors
- Proper initialization order of all providers
- Graceful error handling in UI
- Play buttons work without exceptions
- 80%+ test coverage for playback features

Timeline
- Phase 1: Day 1 (Datasource Initialization Fix)
- Phase 2: Day 2 (Repository Layer Refactor)
- Phase 3: Day 3 (Provider Dependency Chain Fix)
- Phase 4: Day 4 (UI Integration and Error Handling)

Dependencies
- Complete Phase 1 before starting Phase 2
- Phase 4 requires all previous phases to be completed
- Integration with existing provider system
