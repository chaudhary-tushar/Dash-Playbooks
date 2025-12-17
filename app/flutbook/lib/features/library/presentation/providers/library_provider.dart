// lib/features/library/presentation/providers/library_provider.dart
import 'dart:async';

import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutbook/features/library/presentation/providers/library_notifier.dart';
import 'package:flutbook/features/library/presentation/providers/library_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Riverpod provider for library state
final libraryProvider = NotifierProvider<LibraryNotifier, LibraryState>(
  LibraryNotifier.new,
);

// Search query notifier for debounced search
class SearchQueryNotifier extends Notifier<String> {
  Timer? _debounceTimer;

  @override
  String build() {
    // Set up cleanup for timer
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });

    return ''; // Initial empty search query
  }

  // Update search query with debounce
  void updateSearchQuery(String query) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Set new timer
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (ref.mounted) {
        state = query;
      }
    });
  }
}

// Search query provider using NotifierProvider
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

// Filtered audiobooks provider that filters based on search query
final filteredAudiobooksProvider = Provider<List<Audiobook>>((ref) {
  final libraryState = ref.watch(libraryProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  if (searchQuery.isEmpty) {
    return libraryState.audiobooks;
  }

  // Case-insensitive search across title and author
  final searchLower = searchQuery.toLowerCase();
  return libraryState.audiobooks.where((audiobook) {
    return audiobook.title.toLowerCase().contains(searchLower) ||
        audiobook.author.toLowerCase().contains(searchLower);
  }).toList();
});
