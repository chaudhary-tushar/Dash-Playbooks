// lib/presentation/screens/directory_selection_screen.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class DirectorySelectionScreen extends StatefulWidget {
  const DirectorySelectionScreen({
    required this.onDirectorySelected,
    super.key,
    this.initialDirectory,
  });
  final Function(String) onDirectorySelected;
  final String? initialDirectory;

  @override
  _DirectorySelectionScreenState createState() =>
      _DirectorySelectionScreenState();
}

class _DirectorySelectionScreenState extends State<DirectorySelectionScreen> {
  String? _selectedDirectory;

  @override
  void initState() {
    super.initState();
    _selectedDirectory = widget.initialDirectory;
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
      // Use the error handling infrastructure created earlier
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting directory: $e')),
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
                        _selectedDirectory != null
                            ? _selectedDirectory!
                            : 'No directory selected',
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
                onPressed: () =>
                    widget.onDirectorySelected(_selectedDirectory!),
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
