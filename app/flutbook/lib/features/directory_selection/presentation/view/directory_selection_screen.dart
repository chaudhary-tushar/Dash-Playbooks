// lib/presentation/screens/directory_selection_screen.dart

import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutbook/core/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Screen for selecting a directory containing audiobooks.
///
/// This screen:
/// - Allows user to browse and select a directory
/// - Injects the ScanLibraryUseCase via Riverpod
/// - Executes the scanning workflow when Continue is pressed
/// - Navigates to the Library screen after successful scan
class DirectorySelectionScreen extends ConsumerStatefulWidget {
  const DirectorySelectionScreen({
    this.initialDirectory,
    super.key,
  });

  final String? initialDirectory;

  @override
  ConsumerState<DirectorySelectionScreen> createState() => _DirectorySelectionScreenState();
}

class _DirectorySelectionScreenState extends ConsumerState<DirectorySelectionScreen> {
  late String? _selectedDirectory;

  @override
  void initState() {
    super.initState();
    _selectedDirectory = widget.initialDirectory;
  }

  String mapHostPathToContainer(String originalPath) {
    if (originalPath.startsWith('/home/')) {
      return originalPath.replaceFirst('/home/romeo/', '/host-home/');
    }
    return originalPath;
  }

  Future<void> _selectDirectory() async {
    try {
      final selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory != null) {
        setState(() {
          _selectedDirectory = selectedDirectory;
        });
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting directory: $e')),
      );
    }
  }

  Future<void> _handleContinuePressed() async {
    if (_selectedDirectory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a directory first')),
      );
      return;
    }

    final path = mapHostPathToContainer(_selectedDirectory!);

    try {
      // Get the use case from Riverpod
      final scanUseCase = await ref.read(scanLibraryUseCaseProvider.future);

      // Show loading indicator
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Scanning directory... $path'),
          duration: const Duration(milliseconds: 5000),
        ),
      );

      // Execute the scan
      print('DEBUG - Starting scan for $path');
      final result = await scanUseCase.execute(path);
      print('DEBUG - Scan finished');
      print('Scanned files: ${result.scannedFiles}');
      print('Errors: ${result.errors}');
      print('Elapsed: ${result.elapsedTime}');
      print('Total size: ${result.totalSize}');

      if (!mounted) return;

      // Hide the loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Show result
      final message = result.success
          ? 'Scanned ${result.scannedFiles} files in ${result.elapsedTime.inSeconds}s'
          : 'Scan completed with errors. Check logs for details.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      // Navigate to Library screen after successful scan
      if (result.scannedFiles > 0) {
        Navigator.of(context).pushReplacementNamed('/library');
      }
    } catch (e) {
      print('Error during scan: $e');
      if (!mounted) return;

      // Hide the loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning directory: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Audiobook Directory'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.folder_open,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Select Directory',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Choose the folder where your audiobooks are stored. The app will scan this directory and its subfolders for supported audio files.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.drive_folder_upload_outlined),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Selected Directory:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedDirectory != null
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).dividerColor,
                          width: _selectedDirectory != null ? 2.0 : 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).cardTheme.color,
                      ),
                      child: Text(
                        _selectedDirectory != null ? _selectedDirectory! : 'No directory selected',
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedDirectory != null
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).disabledColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.browse_gallery),
              label: const Text('Browse Directory'),
              onPressed: _selectDirectory,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (_selectedDirectory != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Properly handle the Future returned by _handleContinuePressed
                  unawaited(_handleContinuePressed());
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Continue'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
