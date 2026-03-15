/// Sync state provider for managing library and playback synchronization state.
///
/// Provides state management for sync operations including:
/// - Sync status tracking (idle, syncing, success, error)
/// - Last sync time tracking
/// - Error handling and display
/// - Manual sync trigger
/// - Playback position sync
library;

import 'dart:async';

import 'package:flutbook/core/provider/providers.dart';
import 'package:flutbook/features/player/domain/entities/playback_session.dart';
import 'package:flutbook/features/sync/domain/repositories/library_sync_repository.dart';
import 'package:flutbook/features/sync/domain/repositories/playback_sync_repository.dart';
import 'package:flutbook/features/sync/domain/usecases/sync_library_usecase.dart';
import 'package:flutbook/features/sync/domain/usecases/sync_playback_position_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sync status enumeration.
enum SyncStateStatus {
  /// No sync in progress
  idle,

  /// Sync is currently running
  syncing,

  /// Last sync was successful
  success,

  /// Last sync failed
  error,

  /// Currently offline
  offline,
}

/// Sync state for the library and playback synchronization.
class SyncState {
  const SyncState({
    this.status = SyncStateStatus.idle,
    this.lastSyncTime,
    this.lastPlaybackSyncTime,
    this.pendingSyncCount = 0,
    this.errorMessage,
    this.lastSyncResult,
    this.lastPlaybackSyncResult,
    this.isPlaybackSyncEnabled = true,
  });

  final SyncStateStatus status;
  final DateTime? lastSyncTime;
  final DateTime? lastPlaybackSyncTime;
  final int pendingSyncCount;
  final String? errorMessage;
  final SyncResult? lastSyncResult;
  final PlaybackSyncResult? lastPlaybackSyncResult;
  final bool isPlaybackSyncEnabled;

  bool get isSyncing => status == SyncStateStatus.syncing;
  bool get hasError => status == SyncStateStatus.error;
  bool get isSuccess => status == SyncStateStatus.success;
  bool get isOffline => status == SyncStateStatus.offline;

  SyncState copyWith({
    SyncStateStatus? status,
    DateTime? lastSyncTime,
    DateTime? lastPlaybackSyncTime,
    int? pendingSyncCount,
    String? errorMessage,
    SyncResult? lastSyncResult,
    PlaybackSyncResult? lastPlaybackSyncResult,
    bool? isPlaybackSyncEnabled,
  }) {
    return SyncState(
      status: status ?? this.status,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastPlaybackSyncTime: lastPlaybackSyncTime ?? this.lastPlaybackSyncTime,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
      errorMessage: errorMessage ?? this.errorMessage,
      lastSyncResult: lastSyncResult ?? this.lastSyncResult,
      lastPlaybackSyncResult: lastPlaybackSyncResult ?? this.lastPlaybackSyncResult,
      isPlaybackSyncEnabled: isPlaybackSyncEnabled ?? this.isPlaybackSyncEnabled,
    );
  }
}

/// Notifier for managing sync state.
class SyncNotifier extends Notifier<SyncState> {
  /// Create a new SyncNotifier.
  SyncNotifier();

  @override
  SyncState build() {
    // Initialize sync state
    return const SyncState();
  }

  /// Get the library sync use case.
  SyncLibraryUseCase get _librarySyncUseCase {
    return ref.read(syncLibraryUseCaseProvider);
  }

  /// Get the playback sync use case.
  SyncPlaybackPositionUseCase get _playbackSyncUseCase {
    return ref.read(syncPlaybackPositionUseCaseProvider);
  }

  /// Perform manual library sync.
  ///
  /// Triggers a bidirectional sync between local and remote libraries.
  /// Updates state with sync progress and results.
  Future<void> performSync() async {
    // Update state to syncing
    state = state.copyWith(
      status: SyncStateStatus.syncing,
    );

    try {
      // Check if sync is possible
      final canSync = await _librarySyncUseCase.canSync();
      if (!canSync) {
        state = state.copyWith(
          status: SyncStateStatus.offline,
          errorMessage: 'Cannot sync: User not authenticated or offline',
        );
        return;
      }

      // Execute library sync
      final result = await _librarySyncUseCase.execute();

      // Update state based on result
      if (result.isSuccess) {
        state = state.copyWith(
          status: SyncStateStatus.success,
          lastSyncTime: DateTime.now(),
          lastSyncResult: result,
        );

        // Reset to idle after 3 seconds
        Timer(const Duration(seconds: 3), () {
          if (state.status == SyncStateStatus.success) {
            state = state.copyWith(status: SyncStateStatus.idle);
          }
        });
      } else if (result.hasErrors) {
        state = state.copyWith(
          status: SyncStateStatus.error,
          errorMessage: result.errors.join(', '),
          lastSyncResult: result,
        );
      } else {
        state = state.copyWith(
          status: SyncStateStatus.idle,
          lastSyncResult: result,
        );
      }

      // Update pending sync count
      final pendingCount = await _librarySyncUseCase.getPendingSyncCount();
      state = state.copyWith(pendingSyncCount: pendingCount);
    } catch (e) {
      state = state.copyWith(
        status: SyncStateStatus.error,
        errorMessage: 'Sync failed: $e',
      );
    }
  }

  /// Perform playback position sync.
  ///
  /// Triggers a bidirectional sync between local and remote playback positions.
  Future<void> performPlaybackSync() async {
    if (!state.isPlaybackSyncEnabled) {
      return;
    }

    try {
      final canSync = await _playbackSyncUseCase.canSync();
      if (!canSync) {
        return;
      }

      final result = await _playbackSyncUseCase.execute();

      state = state.copyWith(
        lastPlaybackSyncTime: DateTime.now(),
        lastPlaybackSyncResult: result,
      );
    } catch (e) {
      // Silently fail for playback sync (don't show errors to user)
    }
  }

  /// Upload current playback position to remote.
  ///
  /// Call this when playback position changes.
  Future<void> syncPlaybackPosition(PlaybackSession session) async {
    if (!state.isPlaybackSyncEnabled) {
      return;
    }

    try {
      await _playbackSyncUseCase.uploadPosition(session);
    } catch (e) {
      // Silently fail (will sync later)
    }
  }

  /// Download playback position for an audiobook.
  ///
  /// Returns the remote position if available, null otherwise.
  Future<PlaybackSession?> getRemotePlaybackPosition(String audiobookId) async {
    if (!state.isPlaybackSyncEnabled) {
      return null;
    }

    try {
      return await _playbackSyncUseCase.getPositionForAudiobook(audiobookId);
    } catch (e) {
      return null;
    }
  }

  /// Toggle playback sync enabled state.
  void togglePlaybackSync(bool enabled) {
    state = state.copyWith(isPlaybackSyncEnabled: enabled);
  }

  /// Clear error state.
  void clearError() {
    if (state.hasError) {
      state = state.copyWith(
        status: SyncStateStatus.idle,
      );
    }
  }

  /// Refresh sync status.
  ///
  /// Updates the sync state without performing a full sync.
  Future<void> refreshStatus() async {
    try {
      final lastSyncTime = await _librarySyncUseCase.getLastSyncTime();
      final pendingCount = await _librarySyncUseCase.getPendingSyncCount();

      state = state.copyWith(
        lastSyncTime: lastSyncTime,
        pendingSyncCount: pendingCount,
      );
    } catch (e) {
      // Ignore errors during status refresh
    }
  }
}

/// Provider for sync state management.
final syncProvider = NotifierProvider<SyncNotifier, SyncState>(
  SyncNotifier.new,
);
