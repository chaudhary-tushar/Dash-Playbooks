// lib/presentation/providers/ui_state_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Enum for app state
enum AppState { loading, authenticated, anonymous, error }

// -----------------------------------------------------------------------------
// 1. AppState Provider (formerly StateProvider<AppState>)
// -----------------------------------------------------------------------------

class AppStateNotifier extends Notifier<AppState> {
  @override
  AppState build() => AppState.loading;

  /// Sets the new application state.
  void setState(AppState newState) {
    state = newState;
  }
}

// NotifierProvider for overall app state
final appStateProvider = NotifierProvider<AppStateNotifier, AppState>(AppStateNotifier.new);

// -----------------------------------------------------------------------------
// 2. Current User Provider (formerly StateProvider<String?>)
// -----------------------------------------------------------------------------

class CurrentUserNotifier extends Notifier<String?> {
  @override
  String? build() => null; // Initial state: no user ID

  /// Sets the ID of the currently authenticated user.
  void setCurrentUser(String? userId) {
    state = userId;
  }
}

// NotifierProvider for current user ID
final currentUserProvider = NotifierProvider<CurrentUserNotifier, String?>(CurrentUserNotifier.new);

// -----------------------------------------------------------------------------
// 3. Selected Library Path Provider (formerly StateProvider<String?>)
// -----------------------------------------------------------------------------

class SelectedLibraryPathNotifier extends Notifier<String?> {
  @override
  String? build() => null; // Initial state: no selected path

  /// Sets the path of the currently selected library.
  void setPath(String? path) {
    state = path;
  }
}

// NotifierProvider for selected library path
final selectedLibraryPathProvider = NotifierProvider<SelectedLibraryPathNotifier, String?>(
  SelectedLibraryPathNotifier.new,
);

// -----------------------------------------------------------------------------
// 4. Sync Status Provider (formerly StateProvider<bool>)
// -----------------------------------------------------------------------------

class SyncStatusNotifier extends Notifier<bool> {
  @override
  bool build() => false; // Initial state: not syncing

  /// Sets the current sync status.
  void setSyncStatus({required bool isSyncing}) {
    state = isSyncing;
  }

  /// Toggles the sync status.
  void toggle() {
    state = !state;
  }
}

// NotifierProvider for sync status
final syncStatusProvider = NotifierProvider<SyncStatusNotifier, bool>(SyncStatusNotifier.new);

// -----------------------------------------------------------------------------
// 5. Theme Mode Provider (formerly StateProvider<bool>)
// -----------------------------------------------------------------------------

class ThemeModeNotifier extends Notifier<bool> {
  @override
  bool build() => false; // false for light (initial), true for dark

  /// Toggles the application theme mode.
  void toggleTheme() {
    state = !state;
  }
}

// NotifierProvider for theme mode
final themeModeProvider = NotifierProvider<ThemeModeNotifier, bool>(ThemeModeNotifier.new);
