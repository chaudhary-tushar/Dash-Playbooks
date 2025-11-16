// lib/presentation/screens/directory_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class DirectorySelectionScreen extends StatefulWidget {
  final Function(String) onDirectorySelected;
  final String? initialDirectory;

  const DirectorySelectionScreen({
    Key? key,
    required this.onDirectorySelected,
    this.initialDirectory,
  }) : super(key: key);

  @override
  _DirectorySelectionScreenState createState() => _DirectorySelectionScreenState();
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
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      
      if (selectedDirectory != null) {
        setState(() {
          _selectedDirectory = selectedDirectory;
        });
      }
    } catch (e) {
      // Use the error handling infrastructure created earlier
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting directory: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Audiobook Directory'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.folder_open,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 24),
            Text(
              'Select Directory',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 16),
            Text(
              'Choose the folder where your audiobooks are stored. The app will scan this directory and its subfolders for supported audio files.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 32),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.drive_folder_upload_outlined),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Selected Directory:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedDirectory != null
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).dividerColor,
                          width: _selectedDirectory != null ? 2.0 : 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
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
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.browse_gallery),
              label: Text('Browse Directory'),
              onPressed: _selectDirectory,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            if (_selectedDirectory != null) ...[
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => widget.onDirectorySelected(_selectedDirectory!),
                child: Text('Continue'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}