// lib/data/datasources/local/metadata_extraction_datasource.dart
import 'dart:io';

import 'package:flutbook/data/datasources/local/error_handler.dart';
import 'package:flutbook/domain/entities/audiobook.dart';
import 'package:flutbook/domain/entities/chapter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as path;

/// Extracts metadata from audio files using various approaches depending on file format
class MetadataExtractionDatasource {
  /// Extracts metadata from an audio file at the given path
  Future<Audiobook?> extractMetadata(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw FileSystemException('File does not exist: $filePath');
      }

      final fileInfo = await file.stat();
      final fileName = path.basename(filePath);
      final fileExtension = path.extension(filePath).toLowerCase();

      // Default values
      var title = _sanitizeFilename(fileName);
      var author = '';
      const album = '';
      String? coverArtPath;
      Duration? duration;
      var chapters = <Chapter>[];

      try {
        // Use just_audio to extract basic metadata including duration
        final audioPlayer = AudioPlayer();
        await audioPlayer.setFilePath(filePath);
        duration = audioPlayer.duration ?? Duration.zero;

        // Extract ID3 tags or other metadata if available
        if (fileExtension == '.mp3' || fileExtension == '.m4a' || fileExtension == '.m4b') {
          // For MP3 and M4A/M4B files, we'll use basic file parsing
          // In a real implementation, we might use dart:mirrors or a metadata library
          // For now, we'll derive basic info from filename and file properties

          // Try to extract title/author from filename format like "Author - Title.mp3"
          final extractedInfo = _extractInfoFromFilename(fileName);
          if (extractedInfo.title.isNotEmpty) title = extractedInfo.title;
          if (extractedInfo.author.isNotEmpty) author = extractedInfo.author;
        }

        // Additional processing for m4b files with chapter support
        if (fileExtension == '.m4b') {
          chapters = await _extractChaptersFromM4b(filePath);
        }

        // Close the audio player
        await audioPlayer.dispose();
      } catch (e) {
        // If metadata extraction fails, fall back to filename and basic info
        print('Warning: Failed to extract metadata for $filePath: $e');
        // Continue with filename-derived info
      }

      return Audiobook(
        id: _generateId(filePath),
        title: title,
        author: author,
        album: album,
        coverArtPath: coverArtPath,
        duration: duration ?? Duration.zero,
        filePath: filePath,
        chapters: chapters,
        createdAt: DateTime.now(),
        completed: false,
        totalSize: fileInfo.size,
      );
    } catch (e) {
      print('Error extracting metadata from $filePath: $e');
      return null;
    }
  }

  /// Scans a directory recursively for supported audio files
  Future<List<String>> scanDirectoryForAudioFiles(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        throw FileSystemException('Directory does not exist: $directoryPath');
      }

      final audioFiles = <String>[];
      final extensions = ['.mp3', '.m4a', '.m4b', '.wav', '.flac'];

      await for (final FileSystemEntity entity in directory.list(recursive: true)) {
        if (entity is File) {
          final ext = path.extension(entity.path).toLowerCase();
          if (extensions.contains(ext)) {
            audioFiles.add(entity.path);
          }
        }
      }

      return audioFiles;
    } catch (e) {
      print('Error scanning directory $directoryPath: $e');
      rethrow;
    }
  }

  /// Sanitizes a filename by removing extension and cleaning up special characters
  String _sanitizeFilename(String fileName) {
    // Remove extension
    final nameWithoutExt = fileName.substring(0, fileName.lastIndexOf('.'));

    // Remove common prefixes like track numbers (01-, 001-, etc.)
    final cleaned = nameWithoutExt.replaceAll(RegExp(r'^\d+[-_]\s*'), '').trim();

    return cleaned;
  }

  /// Attempts to extract author and title from filename patterns like "Author - Title.mp3"
  ({String title, String author}) _extractInfoFromFilename(String fileName) {
    final nameWithoutExt = fileName.substring(0, fileName.lastIndexOf('.'));
    final parts = nameWithoutExt.split(' - ');

    if (parts.length >= 2) {
      return (author: parts[0].trim(), title: parts.sublist(1).join(' - ').trim());
    }

    return (author: '', title: _sanitizeFilename(fileName));
  }

  /// Generates a unique ID based on file path
  String _generateId(String filePath) {
    // Use a simple hash of the file path to generate a unique ID
    // In production, this should use a proper hashing function
    return filePath.hashCode.toString();
  }

  /// Extracts chapter information from m4b files
  Future<List<Chapter>> _extractChaptersFromM4b(String filePath) async {
    // In a real implementation, we would use a proper library to parse chapter data from m4b files
    // For now, we'll return an empty list as placeholder
    // Possible libraries to implement this: dart:ffi with FFmpeg bindings or similar
    return [];
  }

  /// Extracts cover art from audio file if available
  /// Returns path to temporary file with cover art, or null if none found
  Future<String?> _extractCoverArt(String filePath) async {
    // In a real implementation, we would extract cover art from the audio file's metadata
    // For now, return null as placeholder
    // Possible approach: use a package that can extract images from metadata
    return null;
  }

  /// Validates if a file is accessible and readable
  Future<bool> isFileAccessible(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return false;
      }

      final fileStat = await file.stat();
      return fileStat.type == FileSystemEntityType.file;
    } catch (e) {
      print('File access check failed for $filePath: $e');
      return false;
    }
  }
}
