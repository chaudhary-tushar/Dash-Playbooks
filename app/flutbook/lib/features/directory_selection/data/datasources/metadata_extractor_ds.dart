// lib/data/datasources/local/metadata_extraction_datasource.dart
import 'dart:io';

import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutbook/features/library/domain/entities/chapter.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as path;

/// Extracts metadata from audio files and directories.
///
/// Responsibilities:
/// - Scanning directories for audio files
/// - Extracting metadata from individual files
/// - Creating Audiobook objects from directories (multi-file audiobooks)
/// - Validating file access
class MetadataExtractionDatasource {
  MetadataExtractionDatasource();

  static const _supportedExtensions = ['.mp3', '.m4a', '.m4b', '.wav', '.flac', '.ogg', '.aac'];

  // Common bitrates (bytes/second) used for duration estimation when audio parsing is unavailable
  static const _estimatedBytesPerSecond = 16000; // ~128 kbps MP3

  /// Extracts metadata from an audio file at the given path.
  Future<Audiobook?> extractMetadata(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw FileSystemException('File does not exist: $filePath');
      }

      final fileInfo = await file.stat();
      final fileName = path.basename(filePath);
      final fileExtension = path.extension(filePath).toLowerCase();

      var title = _sanitizeFilename(fileName);
      var author = '';
      String? coverArtPath;
      var duration = Duration.zero;
      var chapters = <Chapter>[];

      // Try to extract accurate duration; fall back to size-based estimate.
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        // Use just_audio only on mobile where it's properly supported.
        try {
          final player = AudioPlayer();
          try {
            await player.setFilePath(filePath);
            duration = player.duration ?? Duration.zero;
          } finally {
            await player.dispose();
          }

          final extracted = _extractInfoFromFilename(fileName);
          if (extracted.title.isNotEmpty) title = extracted.title;
          if (extracted.author.isNotEmpty) author = extracted.author;

          if (fileExtension == '.m4b') {
            chapters = await _extractChaptersFromM4b(filePath, duration);
          }
        } catch (_) {
          duration = _estimateDurationFromSize(fileInfo.size);
          final extracted = _extractInfoFromFilename(fileName);
          if (extracted.title.isNotEmpty) title = extracted.title;
          if (extracted.author.isNotEmpty) author = extracted.author;
        }
      } else {
        // Desktop / web: estimate from file size without reading file content.
        duration = _estimateDurationFromSize(fileInfo.size);
        final extracted = _extractInfoFromFilename(fileName);
        if (extracted.title.isNotEmpty) title = extracted.title;
        if (extracted.author.isNotEmpty) author = extracted.author;
      }

      // Look for cover art in the same directory as the file.
      coverArtPath = await _findCoverArtInDirectory(path.dirname(filePath));

      return Audiobook(
        id: generateFileId(filePath),
        title: title,
        author: author,
        album: '',
        coverArtPath: coverArtPath,
        duration: duration,
        filePath: filePath,
        chapters: chapters,
        createdAt: DateTime.now(),
        completed: false,
        totalSize: fileInfo.size,
      );
    } catch (e) {
      debugPrint('Error extracting metadata from $filePath: $e');
      return null;
    }
  }

  /// Creates a single Audiobook representing an entire directory of audio files.
  ///
  /// Files are sorted naturally (01, 02, … or track01, track02, …) and each
  /// becomes a chapter. The directory name is used as the title.
  Future<Audiobook?> extractDirectoryMetadata(
    String directoryPath,
    List<String> filePaths,
  ) async {
    try {
      if (filePaths.isEmpty) return null;

      // Sort files in natural order so chapters play in sequence.
      final sortedFiles = List<String>.from(filePaths)..sort(_naturalFileSort);

      var totalDuration = Duration.zero;
      var totalSize = 0;
      final chapters = <Chapter>[];
      var author = '';

      for (final filePath in sortedFiles) {
        final file = File(filePath);
        if (!await file.exists()) continue;

        final fileInfo = await file.stat();
        final fileDuration = await _extractFileDuration(filePath, fileInfo.size);
        final chapterTitle = _extractChapterTitle(filePath);

        chapters.add(
          Chapter(
            id: generateFileId(filePath),
            title: chapterTitle,
            startTime: totalDuration,
            endTime: totalDuration + fileDuration,
            filePath: filePath,
          ),
        );

        totalDuration += fileDuration;
        totalSize += fileInfo.size;

        // Use author info from the first file that has it.
        if (author.isEmpty) {
          final extracted = _extractInfoFromFilename(path.basename(filePath));
          if (extracted.author.isNotEmpty) author = extracted.author;
        }
      }

      final dirName = path.basename(directoryPath);
      final title = _cleanDirectoryName(dirName);
      final coverArtPath = await _findCoverArtInDirectory(directoryPath);

      return Audiobook(
        id: generateDirectoryId(directoryPath),
        title: title,
        author: author,
        album: '',
        coverArtPath: coverArtPath,
        duration: totalDuration,
        filePath: sortedFiles.first,
        chapters: chapters,
        createdAt: DateTime.now(),
        completed: false,
        totalSize: totalSize,
      );
    } catch (e) {
      debugPrint('Error extracting directory metadata from $directoryPath: $e');
      return null;
    }
  }

  /// Scans a directory recursively for supported audio files.
  Future<List<String>> scanDirectoryForAudioFiles(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        throw FileSystemException('Directory does not exist: $directoryPath');
      }

      final audioFiles = <String>[];
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          final ext = path.extension(entity.path).toLowerCase();
          if (_supportedExtensions.contains(ext)) {
            audioFiles.add(entity.path);
          }
        }
      }

      return audioFiles;
    } catch (e) {
      debugPrint('Error scanning directory $directoryPath: $e');
      rethrow;
    }
  }

  /// Checks whether a file is accessible and readable.
  Future<bool> isFileAccessible(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;
      final stat = await file.stat();
      return stat.type == FileSystemEntityType.file;
    } catch (e) {
      debugPrint('File access check failed for $filePath: $e');
      return false;
    }
  }

  /// Generates a stable ID for a single audio file.
  String generateFileId(String filePath) => filePath.hashCode.abs().toString();

  /// Generates a stable ID for a directory-level audiobook.
  String generateDirectoryId(String directoryPath) =>
      'dir_${directoryPath.hashCode.abs()}';

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Estimates duration from file size using a typical 128 kbps bitrate.
  /// Never reads file content — uses the size from FileStat.
  Duration _estimateDurationFromSize(int bytes) {
    final seconds = bytes ~/ _estimatedBytesPerSecond;
    return Duration(seconds: seconds.clamp(1, 1000000));
  }

  /// Extracts duration for a single file using just_audio on mobile,
  /// or size-based estimation on desktop/web.
  Future<Duration> _extractFileDuration(String filePath, int fileSize) async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        final player = AudioPlayer();
        try {
          await player.setFilePath(filePath);
          return player.duration ?? _estimateDurationFromSize(fileSize);
        } finally {
          await player.dispose();
        }
      } catch (_) {
        return _estimateDurationFromSize(fileSize);
      }
    }
    return _estimateDurationFromSize(fileSize);
  }

  /// Searches the given directory for common cover art filenames.
  Future<String?> _findCoverArtInDirectory(String directoryPath) async {
    if (kIsWeb) return null;
    final candidates = [
      'cover.jpg', 'cover.jpeg', 'cover.png',
      'folder.jpg', 'folder.jpeg', 'folder.png',
      'album.jpg', 'album.jpeg', 'album.png',
      'artwork.jpg', 'artwork.png',
    ];
    for (final name in candidates) {
      final file = File(path.join(directoryPath, name));
      if (await file.exists()) return file.path;
    }
    return null;
  }

  /// Strips extension, removes leading track numbers, and trims whitespace.
  String _sanitizeFilename(String fileName) {
    final nameWithoutExt = path.basenameWithoutExtension(fileName);
    return nameWithoutExt.replaceAll(RegExp(r'^\d+[-_.\s]+'), '').trim();
  }

  /// Tries to parse "Author - Title.ext" filename patterns.
  ({String title, String author}) _extractInfoFromFilename(String fileName) {
    final nameWithoutExt = path.basenameWithoutExtension(fileName);
    final parts = nameWithoutExt.split(' - ');
    if (parts.length >= 2) {
      return (author: parts[0].trim(), title: parts.sublist(1).join(' - ').trim());
    }
    return (author: '', title: _sanitizeFilename(fileName));
  }

  /// Derives a clean chapter title from a file path.
  String _extractChapterTitle(String filePath) {
    return _sanitizeFilename(path.basename(filePath));
  }

  /// Cleans a directory name for use as an audiobook title.
  String _cleanDirectoryName(String dirName) {
    return dirName
        .replaceAll(RegExp(r'[_\-]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Natural sort comparator for filenames: "02 - Title" < "10 - Title".
  int _naturalFileSort(String a, String b) {
    final nameA = path.basename(a).toLowerCase();
    final nameB = path.basename(b).toLowerCase();

    // Extract leading number sequences for numeric comparison.
    final numA = RegExp(r'^(\d+)').firstMatch(nameA)?.group(1);
    final numB = RegExp(r'^(\d+)').firstMatch(nameB)?.group(1);

    if (numA != null && numB != null) {
      final diff = int.parse(numA) - int.parse(numB);
      if (diff != 0) return diff;
    }

    return nameA.compareTo(nameB);
  }

  /// Placeholder for M4B chapter extraction (requires a dedicated library).
  Future<List<Chapter>> _extractChaptersFromM4b(
    String filePath,
    Duration duration,
  ) async {
    if (duration.inSeconds <= 0) return [];
    return [
      Chapter(
        id: '${generateFileId(filePath)}_full',
        title: path.basenameWithoutExtension(filePath),
        startTime: Duration.zero,
        endTime: duration,
        filePath: filePath,
      ),
    ];
  }
}
