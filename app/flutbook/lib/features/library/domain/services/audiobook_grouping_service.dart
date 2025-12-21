// lib/features/library/domain/services/audiobook_grouping_service.dart
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutbook/features/library/domain/entities/audiobook_group.dart';
import 'package:path/path.dart' as path;

class AudiobookGroupingService {
  /// Groups audiobooks by metadata first (including series detection), then by directory name as fallback
  ///
  /// Returns a list of AudiobookGroup objects, with ungrouped audiobooks
  /// wrapped in individual groups.
  List<AudiobookGroup> groupAudiobooks(List<Audiobook> audiobooks) {
    if (audiobooks.isEmpty) {
      return [];
    }

    // First, try to group by metadata (title + author, with series detection)
    final metadataGroups = _groupByMetadata(audiobooks);

    // If metadata grouping didn't work well (too many small groups),
    // try directory-based grouping as fallback
    if (_shouldUseDirectoryFallback(metadataGroups, audiobooks)) {
      return _groupByDirectory(audiobooks);
    }

    return metadataGroups;
  }

  /// Groups audiobooks by metadata (title + author combination)
  List<AudiobookGroup> _groupByMetadata(List<Audiobook> audiobooks) {
    final groupMap = <String, List<Audiobook>>{};

    for (final audiobook in audiobooks) {
      // Create a group key based on title and author
      final groupKey = _createMetadataGroupKey(audiobook);

      if (groupMap.containsKey(groupKey)) {
        groupMap[groupKey]!.add(audiobook);
      } else {
        groupMap[groupKey] = [audiobook];
      }
    }

    // Convert the map to a list of AudiobookGroup objects
    return groupMap.entries.map((entry) {
      final firstBook = entry.value.first;
      return AudiobookGroup(
        groupKey: entry.key,
        groupName: _createGroupDisplayName(firstBook),
        audiobooks: entry.value,
      );
    }).toList();
  }

  /// Groups audiobooks by directory name
  List<AudiobookGroup> _groupByDirectory(List<Audiobook> audiobooks) {
    final groupMap = <String, List<Audiobook>>{};

    for (final audiobook in audiobooks) {
      final directoryPath = path.dirname(audiobook.filePath);
      final directoryName = path.basename(directoryPath);

      // Use the directory name as the group key
      final groupKey = 'dir_$directoryName';

      if (groupMap.containsKey(groupKey)) {
        groupMap[groupKey]!.add(audiobook);
      } else {
        groupMap[groupKey] = [audiobook];
      }
    }

    // Convert the map to a list of AudiobookGroup objects
    return groupMap.entries.map((entry) {
      final directoryName = entry.key.replaceFirst('dir_', '');
      return AudiobookGroup(
        groupKey: entry.key,
        groupName: directoryName,
        audiobooks: entry.value,
        groupType: 'directory',
      );
    }).toList();
  }

  /// Creates a group key based on audiobook metadata
  String _createMetadataGroupKey(Audiobook audiobook) {
    // Normalize title and author for grouping
    final normalizedTitle = _normalizeString(audiobook.title);
    final normalizedAuthor = _normalizeString(audiobook.author);

    // Try to extract series information from the title
    // Look for patterns like "Series Name Book #", "Book Title Part 1", etc.
    final seriesInfo = _extractSeriesInfo(audiobook.title);

    // Create a composite key
    if (seriesInfo != null) {
      return 'meta_$seriesInfo|$normalizedAuthor';
    }

    return 'meta_$normalizedTitle|$normalizedAuthor';
  }

  /// Extracts series information from title if available
  /// Looks for common patterns in audiobook series
  String? _extractSeriesInfo(String title) {
    // Pattern for "Series Name, Book #"
    final seriesBookPattern = RegExp(r'^(.+?),\s*Book\s+\d+');
    final match1 = seriesBookPattern.firstMatch(title);
    if (match1 != null && match1.groupCount >= 1) {
      return _normalizeString(match1.group(1)!);
    }

    // Pattern for "Book Title - Part #"
    final partPattern = RegExp(r'^(.+?)\s*-\s*Part\s+\d+');
    final match2 = partPattern.firstMatch(title);
    if (match2 != null && match2.groupCount >= 1) {
      return _normalizeString(match2.group(1)!);
    }

    // Pattern for "Book Title, Chapter #"
    final chapterPattern = RegExp(r'^(.+?),\s*Chapter\s+\d+');
    final match3 = chapterPattern.firstMatch(title);
    if (match3 != null && match3.groupCount >= 1) {
      return _normalizeString(match3.group(1)!);
    }

    // Pattern for "Book Title Book #" (without comma)
    final bookNumPattern = RegExp(r'^(.+?)\s+Book\s+\d+');
    final match4 = bookNumPattern.firstMatch(title);
    if (match4 != null && match4.groupCount >= 1) {
      return _normalizeString(match4.group(1)!);
    }

    return null;
  }

  /// Creates a display name for the group
  String _createGroupDisplayName(Audiobook audiobook) {
    final title = audiobook.title.trim();
    final author = audiobook.author.trim();

    // Try to extract series information for better grouping display
    final seriesInfo = _extractSeriesInfo(title);

    if (seriesInfo != null && author.isNotEmpty) {
      return '$seriesInfo by $author (Series)';
    } else if (title.isNotEmpty && author.isNotEmpty) {
      return '$title by $author';
    } else if (title.isNotEmpty) {
      return title;
    } else if (author.isNotEmpty) {
      return 'Works by $author';
    } else {
      return 'Untitled Audiobook';
    }
  }

  /// Normalizes a string for grouping purposes
  String _normalizeString(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '') // Remove special characters
        .replaceAll(RegExp(r'\s+'), ' ') // Collapse multiple spaces
        .trim();
  }

  /// Determines if we should fall back to directory-based grouping
  ///
  /// This happens when metadata grouping results in too many small groups
  /// (indicating that metadata might not be reliable or consistent)
  bool _shouldUseDirectoryFallback(
    List<AudiobookGroup> metadataGroups,
    List<Audiobook> audiobooks,
  ) {
    // If we have very few audiobooks, don't bother with fallback
    if (audiobooks.length <= 3) {
      return false;
    }

    // Calculate average group size
    final averageGroupSize = audiobooks.length / metadataGroups.length;

    // If average group size is very small (less than 2), use directory fallback
    if (averageGroupSize < 2.0) {
      return true;
    }

    // If more than 80% of groups have only 1 audiobook, use directory fallback
    final singleBookGroups = metadataGroups.where((group) => group.audiobooks.length == 1).length;
    final singleBookPercentage = singleBookGroups / metadataGroups.length;

    if (singleBookPercentage > 0.80) {
      return true;
    }

    return false;
  }

  /// Alternative grouping strategy that tries both approaches and picks the better one
  List<AudiobookGroup> groupWithSmartFallback(List<Audiobook> audiobooks) {
    if (audiobooks.isEmpty) {
      return [];
    }

    final metadataGroups = _groupByMetadata(audiobooks);
    final directoryGroups = _groupByDirectory(audiobooks);

    // Choose the grouping strategy that results in more meaningful groups
    // (fewer groups with more items per group)
    if (metadataGroups.length < directoryGroups.length) {
      return metadataGroups; // Metadata grouping is better
    } else {
      return directoryGroups; // Directory grouping is better
    }
  }

  /// Gets all unique group keys from a list of audiobooks (for testing/debugging)
  List<String> getGroupKeys(List<Audiobook> audiobooks) {
    final keys = <String>[];

    for (final audiobook in audiobooks) {
      final metadataKey = _createMetadataGroupKey(audiobook);
      if (!keys.contains(metadataKey)) {
        keys.add(metadataKey);
      }

      final directoryPath = path.dirname(audiobook.filePath);
      final directoryName = path.basename(directoryPath);
      final directoryKey = 'dir_$directoryName';
      if (!keys.contains(directoryKey)) {
        keys.add(directoryKey);
      }
    }

    return keys;
  }
}