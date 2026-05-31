// lib/presentation/screens/library_screen.dart
import 'dart:async';

import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutbook/features/library/presentation/providers/library_notifier.dart';
import 'package:flutbook/features/library/presentation/providers/library_provider.dart';
import 'package:flutbook/features/library/presentation/providers/library_state.dart'
    show AudiobookFilter, LibraryState;
import 'package:flutbook/features/library/presentation/widgets/audiobook_card.dart';
import 'package:flutbook/features/library/presentation/widgets/audiobook_group_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Group expansion state (static, survives rebuilds within a session)
// ---------------------------------------------------------------------------

class GroupExpansionManager {
  static final Map<String, bool> _expandedStates = {};

  static bool isExpanded(String groupKey) => _expandedStates[groupKey] ?? false;

  static void toggle(String groupKey) {
    _expandedStates[groupKey] = !(_expandedStates[groupKey] ?? false);
  }

  static void reset() => _expandedStates.clear();
}

// ---------------------------------------------------------------------------
// Library screen
// ---------------------------------------------------------------------------

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final libraryState = ref.watch(libraryProvider);
    final libraryNotifier = ref.read(libraryProvider.notifier);
    final searchNotifier = ref.read(searchQueryProvider.notifier);
    final filteredAudiobooks = ref.watch(filteredAudiobooksProvider);

    final currentFilter = libraryState.filter ?? const AudiobookFilter();
    final currentSortBy = libraryState.sortBy ?? 'recent';
    final currentSearchQuery = ref.watch(searchQueryProvider);
    final currentStatusFilter = currentFilter.statusFilter;
    final currentViewType = libraryState.viewType;

    // Keep controller text in sync when the search state is cleared externally
    // (e.g. filter reset), but avoid fighting the user while they type.
    if (currentSearchQuery.isEmpty && _searchController.text.isNotEmpty) {
      // Schedule after build to avoid setState-during-build errors.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchController.clear();
      });
    }

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
              libraryState.groupingEnabled ? Icons.folder_special : Icons.folder,
            ),
            onPressed: () => unawaited(libraryNotifier.toggleGrouping()),
            tooltip: libraryState.groupingEnabled ? 'Disable Grouping' : 'Enable Grouping',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              if (value == 'refresh') {
                GroupExpansionManager.reset();
                unawaited(libraryNotifier.refreshLibrary());
              } else if (value == 'settings') {
                unawaited(Navigator.pushNamed(context, '/settings'));
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh Library'),
                  ],
                ),
              ),
              PopupMenuItem(
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
        onRefresh: () async {
          GroupExpansionManager.reset();
          await libraryNotifier.refreshLibrary();
        },
        child: _buildBody(
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

  Widget _buildBody(
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
    return CustomScrollView(
      slivers: [
        // ---- Filter / sort / search card ----
        SliverToBoxAdapter(
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search bar — controller is owned by State, no leak.
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search audiobooks…',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: currentSearchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                searchNotifier.updateSearchQuery('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: searchNotifier.updateSearchQuery,
                  ),

                  const SizedBox(height: 16),

                  // Status filter buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _filterBtn(context, 'All', 'all', currentStatusFilter, libraryNotifier),
                      _filterBtn(context, 'Reading', 'reading', currentStatusFilter, libraryNotifier),
                      _filterBtn(context, 'Completed', 'completed', currentStatusFilter, libraryNotifier),
                      _filterBtn(context, 'Wishlist', 'wishlist', currentStatusFilter, libraryNotifier),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Sort + view-type row
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _mapSortToUi(currentSortBy),
                          decoration: InputDecoration(
                            labelText: 'Sort by',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'name', child: Text('Name')),
                            DropdownMenuItem(value: 'date', child: Text('Date Added')),
                            DropdownMenuItem(value: 'progress', child: Text('Progress')),
                            DropdownMenuItem(value: 'length', child: Text('Duration')),
                          ],
                          onChanged: (value) {
                            if (value != null) libraryNotifier.updateSorting(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Tooltip(
                        message: libraryState.sortAscending ? 'Ascending' : 'Descending',
                        child: OutlinedButton(
                          onPressed: () {
                            libraryNotifier.updateSorting(
                              currentSortBy,
                              ascending: !libraryState.sortAscending,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: Icon(
                            libraryState.sortAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'list', icon: Icon(Icons.list), label: Text('List')),
                          ButtonSegment(value: 'grid', icon: Icon(Icons.grid_view), label: Text('Grid')),
                        ],
                        selected: {currentViewType},
                        onSelectionChanged: (sel) {
                          if (sel.isNotEmpty) libraryNotifier.updateViewType(sel.first);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // ---- Loading indicator (refresh with existing data) ----
        if (libraryState.isLoading && libraryState.audiobooks.isNotEmpty)
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

        // ---- Main content area ----
        if (libraryState.isLoading && libraryState.audiobooks.isEmpty)
          const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
        else if (libraryState.errorMessage != null)
          _errorState(context, libraryState.errorMessage!, libraryNotifier)
        else if (filteredAudiobooks.isEmpty)
          _emptyState(context, currentSearchQuery)
        else if (libraryState.groupingEnabled && libraryState.audiobookGroups.isNotEmpty)
          _groupedList(context, libraryState)
        else if (currentViewType == 'list')
          _flatList(context, filteredAudiobooks)
        else
          _gridView(context, filteredAudiobooks),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Content slivers
  // ---------------------------------------------------------------------------

  SliverFillRemaining _errorState(
    BuildContext context,
    String message,
    LibraryNotifier notifier,
  ) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Error loading library',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => unawaited(notifier.refreshLibrary()),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  SliverFillRemaining _emptyState(BuildContext context, String searchQuery) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isNotEmpty
                  ? 'No audiobooks match your search'
                  : 'No audiobooks in your library',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                  ),
            ),
            if (searchQuery.isEmpty)
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
    );
  }

  SliverList _groupedList(BuildContext context, LibraryState libraryState) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: libraryState.audiobookGroups.length,
        (context, index) {
          final group = libraryState.audiobookGroups[index];
          final isExpanded = GroupExpansionManager.isExpanded(group.groupKey);
          return AudiobookGroupCard(
            group: group,
            isExpanded: isExpanded,
            onTap: () {
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
            onExpand: () {
              // setState triggers a rebuild so the expand/collapse icon updates.
              setState(() => GroupExpansionManager.toggle(group.groupKey));
            },
          );
        },
      ),
    );
  }

  SliverList _flatList(BuildContext context, List<Audiobook> audiobooks) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: audiobooks.length,
        (context, index) => _audiobookCard(context, audiobooks[index]),
      ),
    );
  }

  SliverGrid _gridView(BuildContext context, List<Audiobook> audiobooks) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: audiobooks.length,
        (context, index) => _audiobookCard(context, audiobooks[index]),
      ),
    );
  }

  Widget _audiobookCard(BuildContext context, Audiobook audiobook) {
    final progress = audiobook.lastPlayedAt != null && audiobook.duration.inSeconds > 0
        ? (audiobook.currentPosition.inSeconds / audiobook.duration.inSeconds).clamp(0.0, 1.0)
        : null;
    return AudiobookCard(
      title: audiobook.title,
      author: audiobook.author,
      coverArtPath: audiobook.coverArtPath,
      duration: audiobook.duration,
      isCompleted: audiobook.completed,
      progress: progress,
      audiobook: audiobook,
      onTap: () => unawaited(
        Navigator.pushNamed(context, '/playback', arguments: audiobook),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Small helpers
  // ---------------------------------------------------------------------------

  Widget _filterBtn(
    BuildContext context,
    String label,
    String value,
    String current,
    LibraryNotifier notifier,
  ) {
    final active = current == value;
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: active
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          foregroundColor: active
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurfaceVariant,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () => notifier.updateStatusFilter(value),
        child: Text(label),
      ),
    );
  }

  String _mapSortToUi(String? sortValue) {
    switch (sortValue) {
      case 'title':
        return 'name';
      case 'dateAdded':
      case 'recent':
        return 'date';
      case 'progress':
        return 'progress';
      case 'length':
        return 'length';
      default:
        return sortValue ?? 'name';
    }
  }
}

// ---------------------------------------------------------------------------
// Search delegate
// ---------------------------------------------------------------------------

class _AudiobookSearchDelegate extends SearchDelegate<Audiobook> {
  _AudiobookSearchDelegate({required this.audiobooks});

  final List<Audiobook> audiobooks;

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, Audiobook.empty()),
      );

  @override
  Widget buildResults(BuildContext context) => _resultsList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _resultsList(context);

  Widget _resultsList(BuildContext context) {
    final q = query.toLowerCase();
    final results = q.isEmpty
        ? audiobooks
        : audiobooks
            .where((b) =>
                b.title.toLowerCase().contains(q) ||
                b.author.toLowerCase().contains(q))
            .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final book = results[index];
        return ListTile(
          leading: const Icon(Icons.audiotrack),
          title: Text(book.title),
          subtitle: Text(book.author.isEmpty ? 'Unknown author' : book.author),
          onTap: () => close(context, book),
        );
      },
    );
  }
}
