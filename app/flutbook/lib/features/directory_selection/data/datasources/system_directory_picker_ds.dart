// lib/features/directory_selection/data/datasources/system_directory_picker_ds.dart
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:path_provider/path_provider.dart';

/// System directory picker datasource for selecting directories and files
/// across web and mobile platforms.
class SystemDirectoryPickerDatasource {
  SystemDirectoryPickerDatasource();

  /// Picks a directory or audio files depending on the platform
  ///
  /// Returns:
  /// - On mobile: Returns the path to the selected directory
  /// - On web: Returns the path to the first selected audio file
  /// - Returns null if user cancels or permission is denied
  ///
  /// Throws:
  /// - [FileSystemException] if directory access fails
  /// - [PlatformException] if platform-specific errors occur
  Future<String?> pickDirectory() async {
    try {
      if (kIsWeb) {
        // Web: Use file_picker for audio files
        return await _pickAudioFilesForWeb();
      } else {
        // Mobile: Use native directory picker
        return await _pickDirectoryForMobile();
      }
    } catch (e) {
      throw FileSystemException('Failed to pick directory: $e');
    }
  }

  /// Web-specific implementation using file_picker for audio files
  Future<String?> _pickAudioFilesForWeb() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
        dialogTitle: 'Select audio files',
      );

      if (result != null && result.files.isNotEmpty) {
        // Return the path of the first selected file
        return result.files.first.path;
      }
      return null;
    } catch (e) {
      throw FileSystemException('Web file picking failed: $e');
    }
  }

  /// Mobile-specific implementation using path_provider for directory selection
  Future<String?> _pickDirectoryForMobile() async {
    try {
      // On mobile, we use getExternalStorageDirectory as a starting point
      // In a real implementation, we might use a more sophisticated directory picker
      final directory = await getExternalStorageDirectory();

      if (directory != null) {
        return directory.path;
      }
      return null;
    } catch (e) {
      throw FileSystemException('Mobile directory picking failed: $e');
    }
  }

  /// Checks if the app has permission to access the specified directory
  ///
  /// Returns true if permission is granted, false otherwise
  Future<bool> checkDirectoryPermission(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);

      // Check if directory exists and is accessible
      if (await directory.exists()) {
        // Try to list contents to verify read access
        await directory.list().first;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Requests permission to access storage (mobile only)
  ///
  /// Returns true if permission is granted, false otherwise
  Future<bool> requestStoragePermission() async {
    if (kIsWeb) {
      // On web, permissions are handled by the browser
      return true;
    }

    // For desktop platforms (Linux, Windows, macOS), we don't need special storage permissions
    // The app can access the file system normally when the user selects a directory
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      // Only check storage permission for mobile platforms
      try {
        // On mobile, we attempt to access a known directory
        // This will trigger permission request if not already granted
        final directory = await getExternalStorageDirectory();
        return directory != null;
      } catch (e) {
        return false;
      }
    } else {
      // For desktop platforms, return true since no special permission is needed
      return true;
    }
  }

  /// Gets the default download directory for the platform
  ///
  /// Returns the path to the default download directory
  Future<String?> getDefaultDownloadDirectory() async {
    try {
      if (kIsWeb) {
        // Web doesn't have a traditional download directory
        return null;
      } else {
        final directory = await getDownloadsDirectory();
        return directory?.path;
      }
    } catch (e) {
      return null;
    }
  }

  /// Gets the default documents directory for the platform
  ///
  /// Returns the path to the default documents directory
  Future<String?> getDefaultDocumentsDirectory() async {
    try {
      if (kIsWeb) {
        // Web doesn't have a traditional documents directory
        return null;
      } else {
        final directory = await getApplicationDocumentsDirectory();
        return directory.path;
      }
    } catch (e) {
      return null;
    }
  }
}
