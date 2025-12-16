// lib/presentation/screens/settings_screen.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  // Mock settings values - will be replaced with actual state management
  bool _darkMode = false;
  double _defaultSpeed = 1;
  int _skipInterval = 30;
  bool _syncEnabled = false;
  String _libraryPath = '/storage/emulated/0/Audiobooks';
  bool _autoDownload = false;
  bool _reduceAnimations = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Profile section (for logged-in users)
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: const Text('Anonymous User'),
                    subtitle: const Text('No account connected'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Handle profile tap
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.login),
                        label: const Text('Sign In'),
                        onPressed: () {
                          // Navigate to auth screen
                        },
                      ),
                      FilledButton.icon(
                        icon: const Icon(Icons.folder),
                        label: const Text('Change Library'),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'PLAYBACK',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: _darkMode,
                  onChanged: (bool value) {
                    setState(() {
                      _darkMode = value;
                    });
                  },
                  secondary: const Icon(Icons.dark_mode_outlined),
                ),

                // Default playback speed
                ListTile(
                  title: const Text('Default Playback Speed'),
                  subtitle: Text('${_defaultSpeed}x'),
                  leading: const Icon(Icons.speed),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showPlaybackSpeedDialog,
                ),

                // Skip interval
                ListTile(
                  title: const Text('Default Skip Interval'),
                  subtitle: Text('$_skipInterval seconds'),
                  leading: const Icon(Icons.fast_forward),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showSkipIntervalDialog,
                ),
              ],
            ),
          ),

          // Library Settings
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'LIBRARY',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Audiobook Directory'),
                  subtitle: Text(_libraryPath),
                  leading: const Icon(Icons.folder),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _selectLibraryDirectory,
                ),

                SwitchListTile(
                  title: const Text('Auto Download Covers'),
                  value: _autoDownload,
                  onChanged: (bool value) {
                    setState(() {
                      _autoDownload = value;
                    });
                  },
                  secondary: const Icon(Icons.download),
                ),

                SwitchListTile(
                  title: const Text('Reduce Animations'),
                  value: _reduceAnimations,
                  onChanged: (bool value) {
                    setState(() {
                      _reduceAnimations = value;
                    });
                  },
                  secondary: const Icon(Icons.animation_outlined),
                ),

                ListTile(
                  title: const Text('Rescan Library'),
                  leading: const Icon(Icons.refresh),
                  onTap: () {
                    // Handle library rescan
                  },
                ),
              ],
            ),
          ),

          // Account Settings
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'ACCOUNT',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Enable Sync'),
                  value: _syncEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      _syncEnabled = value;
                    });
                  },
                  secondary: const Icon(Icons.sync),
                ),

                ListTile(
                  title: const Text('Manage Account'),
                  leading: const Icon(Icons.account_box),
                  trailing: const Icon(Icons.chevron_right),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'APP INFO',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  title: const Text('About'),
                  leading: const Icon(Icons.info_outline),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showAboutDialog,
                ),

                ListTile(
                  title: const Text('Privacy Policy'),
                  leading: const Icon(Icons.privacy_tip_outlined),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Handle privacy policy
                  },
                ),

                ListTile(
                  title: const Text('Rate this App'),
                  leading: const Icon(Icons.star_border_outlined),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Handle rating
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _selectLibraryDirectory() async {
    try {
      final selectedDirectory = await FilePicker.platform.getDirectoryPath();

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
            content: const Text('Error selecting directory'),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      }
    }
  }

  Future<void> _showPlaybackSpeedDialog() async {
    await showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        var currentSpeed = _defaultSpeed;

        return AlertDialog(
          title: const Text('Default Playback Speed'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${currentSpeed}x'),
                  Slider(
                    value: currentSpeed,
                    min: 0.5,
                    max: 3,
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
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('SAVE'),
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
        var currentInterval = _skipInterval;

        return AlertDialog(
          title: const Text('Default Skip Interval'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<int>(
                    title: const Text('10 seconds'),
                    value: 10,
                    groupValue: currentInterval,
                    onChanged: (int? value) {
                      if (value != null) {
                        setState(() {
                          currentInterval = value;
                        });
                      }
                    },
                  ),
                  RadioListTile<int>(
                    title: const Text('15 seconds'),
                    value: 15,
                    groupValue: currentInterval,
                    onChanged: (int? value) {
                      if (value != null) {
                        setState(() {
                          currentInterval = value;
                        });
                      }
                    },
                  ),
                  RadioListTile<int>(
                    title: const Text('30 seconds'),
                    value: 30,
                    groupValue: currentInterval,
                    onChanged: (int? value) {
                      if (value != null) {
                        setState(() {
                          currentInterval = value;
                        });
                      }
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('SAVE'),
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
        return const AboutDialog(
          applicationName: 'Flutter Audiobook Player',
          applicationVersion: '1.0.0',
          applicationIcon: Icon(Icons.headset, size: 40),
          children: [
            Text(
              'A privacy-friendly, offline-first audiobook player built with Flutter.',
            ),
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
