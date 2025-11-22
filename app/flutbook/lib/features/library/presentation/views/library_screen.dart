// lib/presentation/screens/library_screen.dart
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutbook/features/library/presentation/widgets/audiobook_card.dart';
import 'package:flutter/material.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  // Temporary: Will be replaced with Riverpod state management
  List<Audiobook> _audiobooks = [];
  String _searchQuery = '';
  bool _showCompleted = true;
  bool _showInProgress = true;
  bool _showNotStarted = true;
  String _sortBy = 'recent'; // Options: 'recent', 'title', 'author'

  @override
  void initState() {
    super.initState();
    // Load library from repository
    _loadLibrary();
  }

  Future<void> _loadLibrary() async {
    // TODO: Connect to actual repository once implemented
    // For now, we'll use mock data to demonstrate the UI
    setState(() {
      _audiobooks = _mockAudiobooks;
    });
  }

  Future<void> _refreshLibrary() async {
    // TODO: Refresh library from file system
    _loadLibrary();
  }

  List<Audiobook> get _filteredAudiobooks {
    final filtered = _audiobooks.where((book) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.author.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus =
          (book.completed && _showCompleted) ||
          (!book.completed && book.lastPlayedAt != null && _showInProgress) ||
          (!book.completed && book.lastPlayedAt == null && _showNotStarted);

      return matchesSearch && matchesStatus;
    }).toList();

    // Sort the results
    switch (_sortBy) {
      case 'title':
        filtered.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
      case 'author':
        filtered.sort(
          (a, b) => a.author.toLowerCase().compareTo(b.author.toLowerCase()),
        );
      case 'recent':
      default:
        filtered.sort(
          (a, b) => (b.lastPlayedAt ?? b.createdAt).compareTo(
            a.lastPlayedAt ?? a.createdAt,
          ),
        );
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
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
                  audiobooks: _audiobooks,
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              if (value == 'refresh') {
                _refreshLibrary();
              } else if (value == 'settings') {
                // Navigate to settings
                Navigator.pushNamed(context, '/settings');
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
      body: Column(
        children: [
          // Filters and sorting options
          Card(
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Status filters
                  Text(
                    'Show:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Completed'),
                        selected: _showCompleted,
                        onSelected: (selected) {
                          setState(() {
                            _showCompleted = selected;
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('In Progress'),
                        selected: _showInProgress,
                        onSelected: (selected) {
                          setState(() {
                            _showInProgress = selected;
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Not Started'),
                        selected: _showNotStarted,
                        onSelected: (selected) {
                          setState(() {
                            _showNotStarted = selected;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Sort options
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Recent'),
                        selected: _sortBy == 'recent',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _sortBy = 'recent';
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Title'),
                        selected: _sortBy == 'title',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _sortBy = 'title';
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Author'),
                        selected: _sortBy == 'author',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _sortBy = 'author';
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Audiobook list
          Expanded(
            child: _filteredAudiobooks.isEmpty
                ? Center(
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
                          _searchQuery.isNotEmpty
                              ? 'No audiobooks match your search'
                              : 'No audiobooks in your library',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withAlpha(150),
                          ),
                        ),
                        if (_searchQuery.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Use the directory selector to add audiobooks',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _refreshLibrary,
                    child: ListView.builder(
                      itemCount: _filteredAudiobooks.length,
                      itemBuilder: (context, index) {
                        final audiobook = _filteredAudiobooks[index];
                        return AudiobookCard(
                          title: audiobook.title,
                          author: audiobook.author,
                          coverArtPath: audiobook.coverArtPath,
                          duration: audiobook.duration,
                          isCompleted: audiobook.completed,
                          progress:
                              audiobook.lastPlayedAt != null && audiobook.duration.inSeconds > 0
                              ? (DateTime.now().difference(audiobook.lastPlayedAt!).inSeconds /
                                        audiobook.duration.inSeconds)
                                    .clamp(0.0, 1.0)
                              : null,
                          onTap: () {
                            // Navigate to playback screen
                            Navigator.pushNamed(
                              context,
                              '/playback',
                              arguments: audiobook,
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// Mock data for demonstration
final List<Audiobook> _mockAudiobooks = [
  Audiobook(
    id: '1',
    title: 'The Great Gatsby',
    author: 'F. Scott Fitzgerald',
    album: 'Classic Literature',
    duration: const Duration(hours: 5, minutes: 10),
    filePath: '/storage/emulated/0/Audiobooks/great-gatsby.mp3',
    chapters: [],
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    lastPlayedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    completed: false,
    totalSize: 24567890,
  ),
  Audiobook(
    id: '2',
    title: 'To Kill a Mockingbird',
    author: 'Harper Lee',
    album: 'Classic Literature',
    duration: const Duration(hours: 10, minutes: 33),
    filePath: '/storage/emulated/0/Audiobooks/mockinbird.mp3',
    chapters: [],
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    lastPlayedAt: DateTime.now().subtract(const Duration(days: 1)),
    completed: true,
    totalSize: 48765432,
  ),
  Audiobook(
    id: '3',
    title: '1984',
    author: 'George Orwell',
    album: 'Dystopian Fiction',
    duration: const Duration(hours: 8, minutes: 47),
    filePath: '/storage/emulated/0/Audiobooks/1984.mp3',
    chapters: [],
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
    completed: false,
    totalSize: 40987654,
  ),
];
