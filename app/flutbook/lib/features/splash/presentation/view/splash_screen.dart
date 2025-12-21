// lib/presentation/screens/splash_screen.dart
import 'dart:async';

import 'package:flutbook/core/provider/providers.dart';
import 'package:flutbook/features/auth/data/models/user_profile_model.dart';
import 'package:flutbook/features/library/data/models/audiobook_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Ensure only one user profile exists in the database
    final userProfileService = await ref.read(userProfileServiceProvider.future);
    if (userProfileService != null) {
      await userProfileService.ensureSingleUserProfile();
    }

    // Check if there's a user in ISAR
    final databaseService = await ref.read(databaseServiceProvider.future);
    final userProfile = await databaseService.isar.userProfileModels.where().findFirst();

    if (userProfile != null) {
      // User exists in ISAR, verify with Supabase
      try {
        final supabaseAuthDatasource = ref.read(supabaseAuthDatasourceProvider);
        final supabaseUser = await supabaseAuthDatasource.getCurrentUser();

        // Check if the user still exists in Supabase
        if (supabaseUser != null && supabaseUser.id == userProfile.internalId) {
          // User is verified in both ISAR and Supabase

          // Check if audiobooks exist
          final audiobookCount = await databaseService.isar.audiobookModels.count();
          if (audiobookCount > 0) {
            // Both user and audiobooks exist, go to library
            if (mounted) {
              unawaited(Navigator.of(context).pushReplacementNamed('/library'));
            }
          } else {
            // User exists but no audiobooks, go to directory selection
            if (mounted) {
              unawaited(Navigator.of(context).pushReplacementNamed('/directory'));
            }
          }
        } else {
          // User doesn't exist in Supabase anymore, redirect to login
          if (mounted) {
            unawaited(Navigator.of(context).pushReplacementNamed('/auth'));
          }
        }
      } catch (e) {
        // Error occurred during verification, redirect to login
        if (mounted) {
          unawaited(Navigator.of(context).pushReplacementNamed('/auth'));
        }
      }
    } else {
      // No user in ISAR, redirect to login
      if (mounted) {
        unawaited(Navigator.of(context).pushReplacementNamed('/auth'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.headset,
              size: 100,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            const SizedBox(height: 24),
            Text(
              'Audiobook Player',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your personal audio companion',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 48),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
