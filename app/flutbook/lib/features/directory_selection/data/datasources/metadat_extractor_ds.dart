// lib/data/datasources/local/metadata_extraction_datasource.dart
import 'dart:io';

import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/features/library/domain/entities/audiobook.dart';
import 'package:flutbook/features/library/domain/entities/chapter.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as path;

/// Extracts metadata from audio files using various approaches depending on file format.
///
/// This datasource is responsible ONLY for:
/// - Scanning directories for audio files
/// - Extracting metadata from individual files
/// - Validating file access
///
/// It does NOT handle database operations or depend on AudiobookLocalDatasource.
class MetadataExtractionDatasource {
  MetadataExtractionDatasource();

  /// Extracts metadata from an audio file at the given path
  /// TODO: Integrate audio_tags package for full ID3v2, MP4 tags, cover art extraction, advanced chapter parsing
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
      var duration = Duration.zero; // Initialize with zero as default
      var chapters = <Chapter>[];

      try {
        // For desktop platforms (Linux, Windows, macOS), we'll extract duration using file system approach
        // just_audio doesn't have proper desktop implementation, so we'll fall back to file-based estimation
        if (kIsWeb || (!Platform.isLinux && !Platform.isWindows && !Platform.isMacOS)) {
          // Use just_audio for mobile and web platforms where it's properly implemented
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
            chapters = await _extractChaptersFromM4b(filePath, duration);
          }

          // Close the audio player
          await audioPlayer.dispose();
        } else {
          // For desktop platforms, estimate duration based on file size and standard bitrates
          // This is less accurate but prevents the MissingPluginException
          try {
            final fileData = await file.readAsBytes();
            final fileSizeInBytes = fileData.lengthInBytes;

            // Calculate based on common audio bitrates (in bits per second)
            // 128 kbps (16000 bytes/second) is a common MP3 bitrate
            // 256 kbps (32000 bytes/second) for higher quality
            // Use conservative 128kbps estimation to avoid overestimation
            final estimatedDurationSeconds = (fileSizeInBytes / 16000).round();
            duration = Duration(seconds: estimatedDurationSeconds > 0 ? estimatedDurationSeconds : 1); // Ensure at least 1 second

            // Try to extract title/author from filename format like "Author - Title.mp3"
            final extractedInfo = _extractInfoFromFilename(fileName);
            if (extractedInfo.title.isNotEmpty) title = extractedInfo.title;
            if (extractedInfo.author.isNotEmpty) author = extractedInfo.author;
          } catch (e) {
            // If file reading fails, use minimum duration
            print('Warning: Failed to read file for duration estimation $filePath: $e');
            duration = const Duration(seconds: 1); // Default to 1 second if we can't estimate

            // Try to extract title/author from filename anyway
            final extractedInfo = _extractInfoFromFilename(fileName);
            if (extractedInfo.title.isNotEmpty) title = extractedInfo.title;
            if (extractedInfo.author.isNotEmpty) author = extractedInfo.author;
          }
        }

        coverArtPath = await _extractCoverArt(filePath);
      } catch (e) {
        // If metadata extraction fails, fall back to minimum viable audiobook object
        print('Warning: Failed to extract metadata for $filePath: $e');
        // Set sensible defaults to ensure audiobook object is still valid
        duration = const Duration(seconds: 1); // Default to 1 second

        final extractedInfo = _extractInfoFromFilename(fileName);
        if (extractedInfo.title.isNotEmpty) title = extractedInfo.title;
        if (extractedInfo.author.isNotEmpty) author = extractedInfo.author;
      }

      return Audiobook(
        id: _generateId(filePath),
        title: title,
        author: author,
        album: album,
        coverArtPath: coverArtPath,
        duration: duration,
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

      await for (final FileSystemEntity entity in directory.list(
        recursive: true,
      )) {
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
      return (
        author: parts[0].trim(),
        title: parts.sublist(1).join(' - ').trim(),
      );
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
  Future<List<Chapter>> _extractChaptersFromM4b(String filePath, Duration duration) async {
    // TODO: proper M4B chapter parsing using specialized library
    // For now, dummy full book chapter
    if (duration.inSeconds <= 0) return <Chapter>[];
    return [
      Chapter(
        id: '${_generateId(filePath)}_full',
        title: path.basenameWithoutExtension(filePath),
        startTime: Duration.zero,
        endTime: duration,
      ),
    ];
  }

  /// Extracts cover art from audio file if available
  /// Returns path to temporary file with cover art, or null if none found
  Future<String?> _extractCoverArt(String filePath) async {
    try {
      // For web, we might not be able to extract cover art from files
      // This is an inherent limitation of web platform for security reasons
      if (kIsWeb) {
        // On web, we skip cover art extraction
        return null;
      }

      // For MP3 files, we can use the just_audio library to extract ID3 artwork
      // Note: just_audio doesn't expose cover art directly, so we'll need to use an alternative approach
      // For now, we'll return null and suggest using a metadata library like audio_session
      if (path.extension(filePath).toLowerCase() == '.mp3') {
        // Using just_audio alone doesn't provide direct access to cover art
        // A proper implementation would require using a dedicated metadata library
        // that can extract ID3 tags from audio files
      }

      // For other file types, we could implement additional extraction methods
      // For example, using a dedicated metadata library like audio_tags
      // For now, we'll return null for all files
      return null;
    } catch (e) {
      print('Error extracting cover art from $filePath: $e');
      return null;
    }
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
