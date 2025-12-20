// lib/presentation/screens/library_screen.dart
import 'dart:async';

import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutbook/features/library/domain/entities/audiobook_group.dart';
import 'package:flutbook/features/library/presentation/providers/library_notifier.dart';
import 'package:flutbook/features/library/presentation/providers/library_provider.dart';
import 'package:flutbook/features/library/presentation/providers/library_state.dart'
    show AudiobookFilter, LibraryState;
import 'package:flutbook/features/library/presentation/widgets/audiobook_card.dart';
import 'package:flutbook/features/library/presentation/widgets/audiobook_group_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple state management for group expansion
class _GroupExpandedState {
  _GroupExpandedState(this.groupKey);

  final String groupKey;
  bool isExpanded = false;

  void toggle() {
    isExpanded = !isExpanded;
  }

  void expand() {
    isExpanded = true;
  }

  void collapse() {
    isExpanded = false;
  }
}

// SliverRefreshControl is available in the material package

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the library provider to get the current state
    final libraryState = ref.watch(libraryProvider);
    final libraryNotifier = ref.read(libraryProvider.notifier);
    final searchNotifier = ref.read(searchQueryProvider.notifier);
    final filteredAudiobooks = ref.watch(filteredAudiobooksProvider);

    // Get current filter and sort settings from state
    final currentFilter = libraryState.filter ?? const AudiobookFilter();
    final currentSortBy = libraryState.sortBy ?? 'recent';
    final currentSearchQuery = ref.watch(searchQueryProvider);

    // Get current filter status
    final currentStatusFilter = currentFilter.statusFilter ?? 'all';
    final currentViewType = libraryState.viewType ?? 'list';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Library'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _AudiobookSearchDelegate(
                  audiobooks: libraryState.audiobooks,
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              libraryState.groupingEnabled
                  ? Icons.folder_special
                  : Icons.folder,
            ),
            onPressed: () async {
              await libraryNotifier.toggleGrouping();
            },
            tooltip: libraryState.groupingEnabled
                ? 'Disable Grouping'
                : 'Enable Grouping',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              if (value == 'refresh') {
                unawaited(libraryNotifier.refreshLibrary());
              } else if (value == 'settings') {
                // Navigate to settings
                unawaited(Navigator.pushNamed(context, '/settings'));
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh Library'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: libraryNotifier.refreshLibrary,
        child: _buildLibraryBody(
          context,
          libraryState,
          libraryNotifier,
          filteredAudiobooks,
          currentSearchQuery,
          currentSortBy,
          currentStatusFilter,
          currentViewType,
          searchNotifier,
        ),
      ),
    );
  }

  // Helper method to build the main body of the library screen
  Widget _buildLibraryBody(
    BuildContext context,
    LibraryState libraryState,
    LibraryNotifier libraryNotifier,
    List<Audiobook> filteredAudiobooks,
    String currentSearchQuery,
    String currentSortBy,
    String currentStatusFilter,
    String currentViewType,
    SearchQueryNotifier searchNotifier,
  ) {
    // Use a CustomScrollView to allow scrolling of the entire content
    return CustomScrollView(
      slivers: [
        // Filter section as a sliver
        SliverToBoxAdapter(
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search audiobooks...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: currentSearchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchNotifier.updateSearchQuery('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    controller: TextEditingController(text: currentSearchQuery),
                    onChanged: searchNotifier.updateSearchQuery,
                  ),

                  const SizedBox(height: 16),

                  // Filter buttons: All/Reading/Completed/Wishlist
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFilterButton(
                        context,
                        'All',
                        'all',
                        currentStatusFilter,
                        libraryNotifier,
                      ),
                      _buildFilterButton(
                        context,
                        'Reading',
                        'reading',
                        currentStatusFilter,
                        libraryNotifier,
                      ),
                      _buildFilterButton(
                        context,
                        'Completed',
                        'completed',
                        currentStatusFilter,
                        libraryNotifier,
                      ),
                      _buildFilterButton(
                        context,
                        'Wishlist',
                        'wishlist',
                        currentStatusFilter,
                        libraryNotifier,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Sort dropdown and view toggle row
                  Row(
                    children: [
                      // Sort dropdown
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _mapSortValueToUi(currentSortBy),
                          decoration: InputDecoration(
                            labelText: 'Sort by',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'name',
                              child: Text('Name'),
                            ),
                            DropdownMenuItem(
                              value: 'date',
                              child: Text('Date Added'),
                            ),
                            DropdownMenuItem(
                              value: 'progress',
                              child: Text('Progress'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              libraryNotifier.updateSorting(value);
                            }
                          },
                        ),
                      ),

                      const SizedBox(width: 16),

                      // View toggle: Grid/List
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'list',
                            icon: Icon(Icons.list),
                            label: Text('List'),
                          ),
                          ButtonSegment(
                            value: 'grid',
                            icon: Icon(Icons.grid_view),
                            label: Text('Grid'),
                          ),
                        ],
                        selected: {currentViewType},
                        onSelectionChanged: (Set<String> newSelection) {
                          if (newSelection.isNotEmpty) {
                            libraryNotifier.updateViewType(newSelection.first);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Conditionally show loading indicator at top when refreshing with existing data
        if (libraryState.isLoading && libraryState.audiobooks.isNotEmpty)
          // Show loading indicator at top when refreshing with existing data
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 16, right: 16),
              child: Align(
                alignment: Alignment.topRight,
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),
        if (libraryState.isLoading && libraryState.audiobooks.isEmpty)
          // Loading state
          const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (libraryState.errorMessage != null)
          // Error state
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading library',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    libraryState.errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => libraryNotifier.refreshLibrary(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        else if (filteredAudiobooks.isEmpty)
          // Empty state
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_books_outlined,
                    size: 80,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(100),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentSearchQuery.isNotEmpty
                        ? 'No audiobooks match your search'
                        : 'No audiobooks in your library',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(150),
                    ),
                  ),
                  if (currentSearchQuery.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Use the directory selector to add audiobooks',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          )
        else if (libraryState.groupingEnabled &&
            libraryState.audiobookGroups.isNotEmpty)
          // Grouped audiobook display
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final group = libraryState.audiobookGroups[index];
                return _buildGroupedAudiobookCard(
                  context,
                  group,
                  libraryNotifier,
                );
              },
              childCount: libraryState.audiobookGroups.length,
            ),
          )
        else if (currentViewType == 'list')
          // Audiobook list content
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final audiobook = filteredAudiobooks[index];
                return AudiobookCard(
                  title: audiobook.title,
                  author: audiobook.author,
                  coverArtPath: audiobook.coverArtPath,
                  duration: audiobook.duration,
                  isCompleted: audiobook.completed,
                  progress:
                      audiobook.lastPlayedAt != null &&
                          audiobook.duration.inSeconds > 0
                      ? (DateTime.now()
                                    .difference(audiobook.lastPlayedAt!)
                                    .inSeconds /
                                audiobook.duration.inSeconds)
                            .clamp(0.0, 1.0)
                      : null,
                  onTap: () {
                    // Navigate to playback screen
                    unawaited(
                      Navigator.pushNamed(
                        context,
                        '/playback',
                        arguments: audiobook,
                      ),
                    );
                  },
                );
              },
              childCount: filteredAudiobooks.length,
            ),
          )
        else
          // Grid view using SliverGrid (default case)
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final audiobook = filteredAudiobooks[index];
                return AudiobookCard(
                  title: audiobook.title,
                  author: audiobook.author,
                  coverArtPath: audiobook.coverArtPath,
                  duration: audiobook.duration,
                  isCompleted: audiobook.completed,
                  progress:
                      audiobook.lastPlayedAt != null &&
                          audiobook.duration.inSeconds > 0
                      ? (DateTime.now()
                                    .difference(audiobook.lastPlayedAt!)
                                    .inSeconds /
                                audiobook.duration.inSeconds)
                            .clamp(0.0, 1.0)
                      : null,
                  onTap: () {
                    // Navigate to playback screen
                    unawaited(
                      Navigator.pushNamed(
                        context,
                        '/playback',
                        arguments: audiobook,
                      ),
                    );
                  },
                );
              },
              childCount: filteredAudiobooks.length,
            ),
          ),
      ],
    );
  }

  // Helper method to build grouped audiobook cards
  Widget _buildGroupedAudiobookCard(
    BuildContext context,
    AudiobookGroup group,
    LibraryNotifier notifier,
  ) {
    // Create a state for expanded/collapsed groups
    final groupState = _GroupExpandedState(group.groupKey);

    return AudiobookGroupCard(
      group: group,
      isExpanded: groupState.isExpanded,
      onTap: () {
        // Navigate to the first audiobook in the group
        if (group.audiobooks.isNotEmpty) {
          unawaited(
            Navigator.pushNamed(
              context,
              '/playback',
              arguments: group.audiobooks.first,
            ),
          );
        }
      },
      onExpand: groupState.toggle,
    );
  }

  // Helper method to map backend sort values to UI values
  String _mapSortValueToUi(String? sortValue) {
    if (sortValue == null) return 'name';

    // Map backend values to UI values
    switch (sortValue) {
      case 'title':
        return 'name';
      case 'recent':
        return 'date';
      case 'progress':
        return 'progress';
      default:
        return sortValue; // Return as-is if already a UI value
    }
  }

  // Helper method to build filter buttons with visual feedback
  Widget _buildFilterButton(
    BuildContext context,
    String label,
    String filterValue,
    String currentFilter,
    LibraryNotifier notifier,
  ) {
    final isActive = currentFilter == filterValue;

    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          foregroundColor: isActive
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () {
          notifier.updateStatusFilter(filterValue);
        },
        child: Text(label),
      ),
    );
  }
}

// Search delegate for audiobook search
class _AudiobookSearchDelegate extends SearchDelegate<Audiobook> {
  _AudiobookSearchDelegate({required this.audiobooks});

  final List<Audiobook> audiobooks;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, Audiobook.empty());
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = audiobooks.where((book) {
      return book.title.toLowerCase().contains(query.toLowerCase()) ||
          book.author.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final audiobook = results[index];
        return ListTile(
          title: Text(audiobook.title),
          subtitle: Text(audiobook.author),
          onTap: () {
            close(context, audiobook);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? audiobooks
        : audiobooks.where((book) {
            return book.title.toLowerCase().contains(query.toLowerCase()) ||
                book.author.toLowerCase().contains(query.toLowerCase());
          }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final audiobook = suggestions[index];
        return ListTile(
          title: Text(audiobook.title),
          subtitle: Text(audiobook.author),
          onTap: () {
            query = audiobook.title;
            close(context, audiobook);
          },
        );
      },
    );
  }
}
