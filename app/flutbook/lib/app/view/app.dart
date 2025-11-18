import 'package:flutbook/login/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const MaterialApp(
      title: 'Flutter Audiobook Player',
      debugShowCheckedModeBanner: false,
      home: LoginPage(), // <<< IMPORTANT
    );
  }
}
