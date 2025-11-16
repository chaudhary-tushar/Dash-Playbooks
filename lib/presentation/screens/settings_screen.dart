// lib/presentation/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Mock settings values - will be replaced with actual state management
  bool _darkMode = false;
  double _defaultSpeed = 1.0;
  int _skipInterval = 30;
  bool _syncEnabled = false;
  String _libraryPath = '/storage/emulated/0/Audiobooks';
  bool _autoDownload = false;
  bool _reduceAnimations = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Profile section (for logged-in users)
          Card(
            margin: EdgeInsets.all(16.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text('Anonymous User'),
                    subtitle: Text('No account connected'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      // Handle profile tap
                    },
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton.icon(
                        icon: Icon(Icons.login),
                        label: Text('Sign In'),
                        onPressed: () {
                          // Navigate to auth screen
                        },
                      ),
                      FilledButton.icon(
                        icon: Icon(Icons.folder),
                        label: Text('Change Library'),
                        onPressed: _selectLibraryDirectory,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Playback Settings
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'PLAYBACK',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          Card(
            margin: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('Dark Mode'),
                  value: _darkMode,
                  onChanged: (bool value) {
                    setState(() {
                      _darkMode = value;
                    });
                  },
                  secondary: Icon(Icons.dark_mode_outlined),
                ),
                
                // Default playback speed
                ListTile(
                  title: Text('Default Playback Speed'),
                  subtitle: Text('${_defaultSpeed}x'),
                  leading: Icon(Icons.speed),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    _showPlaybackSpeedDialog();
                  },
                ),
                
                // Skip interval
                ListTile(
                  title: Text('Default Skip Interval'),
                  subtitle: Text('$_skipInterval seconds'),
                  leading: Icon(Icons.fast_forward),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    _showSkipIntervalDialog();
                  },
                ),
              ],
            ),
          ),

          // Library Settings
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'LIBRARY',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          Card(
            margin: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                ListTile(
                  title: Text('Audiobook Directory'),
                  subtitle: Text(_libraryPath),
                  leading: Icon(Icons.folder),
                  trailing: Icon(Icons.chevron_right),
                  onTap: _selectLibraryDirectory,
                ),
                
                SwitchListTile(
                  title: Text('Auto Download Covers'),
                  value: _autoDownload,
                  onChanged: (bool value) {
                    setState(() {
                      _autoDownload = value;
                    });
                  },
                  secondary: Icon(Icons.download),
                ),
                
                SwitchListTile(
                  title: Text('Reduce Animations'),
                  value: _reduceAnimations,
                  onChanged: (bool value) {
                    setState(() {
                      _reduceAnimations = value;
                    });
                  },
                  secondary: Icon(Icons.animation_outlined),
                ),
                
                ListTile(
                  title: Text('Rescan Library'),
                  leading: Icon(Icons.refresh),
                  onTap: () {
                    // Handle library rescan
                  },
                ),
              ],
            ),
          ),

          // Account Settings
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'ACCOUNT',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          Card(
            margin: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('Enable Sync'),
                  value: _syncEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      _syncEnabled = value;
                    });
                  },
                  secondary: Icon(Icons.sync),
                ),
                
                ListTile(
                  title: Text('Manage Account'),
                  leading: Icon(Icons.account_box),
                  trailing: Icon(Icons.chevron_right),
                  enabled: false,
                  onTap: () {
                    // Navigate to account management
                  },
                ),
              ],
            ),
          ),

          // App Info
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'APP INFO',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          Card(
            margin: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                ListTile(
                  title: Text('About'),
                  leading: Icon(Icons.info_outline),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    _showAboutDialog();
                  },
                ),
                
                ListTile(
                  title: Text('Privacy Policy'),
                  leading: Icon(Icons.privacy_tip_outlined),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // Handle privacy policy
                  },
                ),
                
                ListTile(
                  title: Text('Rate this App'),
                  leading: Icon(Icons.star_border_outlined),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // Handle rating
                  },
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _selectLibraryDirectory() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      
      if (selectedDirectory != null) {
        setState(() {
          _libraryPath = selectedDirectory;
        });
      }
    } catch (e) {
      // Show error message using our error handling infrastructure
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting directory'),
            action: SnackBarAction(
              label: 'OK', 
              onPressed: () {}
            ),
          ),
        );
      }
    }
  }

  Future<void> _showPlaybackSpeedDialog() async {
    await showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        double currentSpeed = _defaultSpeed;
        
        return AlertDialog(
          title: Text('Default Playback Speed'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${currentSpeed}x'),
                  Slider(
                    value: currentSpeed,
                    min: 0.5,
                    max: 3.0,
                    divisions: 50,
                    label: '${currentSpeed}x',
                    onChanged: (double value) {
                      setState(() {
                        currentSpeed = double.parse(value.toStringAsFixed(2));
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('SAVE'),
              onPressed: () {
                setState(() {
                  _defaultSpeed = currentSpeed;
                });
                Navigator.of(context).pop(currentSpeed);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSkipIntervalDialog() async {
    await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        int currentInterval = _skipInterval;
        
        return AlertDialog(
          title: Text('Default Skip Interval'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<int>(
                    title: Text('10 seconds'),
                    value: 10,
                    groupValue: currentInterval,
                    onChanged: (int? value) {
                      setState(() {
                        currentInterval = value!;
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: Text('15 seconds'),
                    value: 15,
                    groupValue: currentInterval,
                    onChanged: (int? value) {
                      setState(() {
                        currentInterval = value!;
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: Text('30 seconds'),
                    value: 30,
                    groupValue: currentInterval,
                    onChanged: (int? value) {
                      setState(() {
                        currentInterval = value!;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('SAVE'),
              onPressed: () {
                setState(() {
                  _skipInterval = currentInterval;
                });
                Navigator.of(context).pop(currentInterval);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAboutDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AboutDialog(
          applicationName: 'Flutter Audiobook Player',
          applicationVersion: '1.0.0',
          applicationIcon: Icon(Icons.headset, size: 40),
          children: [
            Text('A privacy-friendly, offline-first audiobook player built with Flutter.'),
            SizedBox(height: 8),
            Text('Features:'),
            Text('• Cross-platform (Android, Linux, Web)'),
            Text('• Offline-first with local storage'),
            Text('• Background playback'),
            Text('• Chapter navigation'),
            Text('• Sleep timer'),
            Text('• Speed control'),
          ],
        );
      },
    );
  }
}