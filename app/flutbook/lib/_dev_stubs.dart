import 'package:flutter/material.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('LibraryScreen stub')),
    );
  }
}

class PlaybackScreen extends StatelessWidget {
  final dynamic audiobook; // ignore real model
  const PlaybackScreen({super.key, required this.audiobook});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('PlaybackScreen stub')),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('SettingsScreen stub')),
    );
  }
}

class AudiobookModel {}
