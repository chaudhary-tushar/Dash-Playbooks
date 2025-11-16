// lib/presentation/providers/ui_state_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Enum for app state
enum AppState { loading, authenticated, anonymous, error }

// State provider for overall app state
final appStateProvider = StateProvider<AppState>((ref) => AppState.loading);

// State provider for current user
final currentUserProvider = StateProvider<String?>((ref) => null);

// State provider for selected library path
final selectedLibraryPathProvider = StateProvider<String?>((ref) => null);

// State provider for sync status
final syncStatusProvider = StateProvider<bool>((ref) => false);

// State provider for theme mode
final themeModeProvider = StateProvider<bool>((ref) => false); // false for light, true for dark