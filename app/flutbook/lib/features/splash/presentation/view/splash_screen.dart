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
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize audio services early to ensure they're ready when needed
      await _initializeAudioServices();

      // Skip pre-initialization of auth and playback providers to avoid provider deadlocks
      // These providers will be initialized naturally when needed by their respective screens

      // Initialize app services and navigate based on auth state
      await _checkAuthAndNavigate();
    } catch (e) {
      // Log the error for debugging
      debugPrint('Splash screen initialization error: $e');

      setState(() {
        _errorMessage = 'Initialization failed: $e';
      });
    }
  }

  /// Initialize audio services to ensure they're ready when the user starts playing audiobooks
  Future<void> _initializeAudioServices() async {
    try {
      // Wait for audio initialization service to complete
      await ref.read(audioInitializationServiceProvider.future);
      print('Audio services initialized successfully in splash screen');
    } catch (e) {
      print('Error initializing audio services in splash screen: $e');
      // Continue with app initialization even if audio services fail to initialize
    }
  }

  /// Pre-initialize auth providers to prevent delays when user tries to login
  /// This ensures all auth-related providers are ready before showing login page
  Future<void> _initializeAuthProviders() async {
    try {
      print('Pre-initializing auth providers...');

      // Initialize user repository (depends on database and user profile service)
      await ref.read(userRepositoryProvider.future);
      print('User repository initialized');

      // Initialize auth use cases (depend on user repository)
      await ref.read(loginUsecaseProvider.future);
      print('Login use case initialized');

      await ref.read(anonymousLoginUsecaseProvider.future);
      print('Anonymous login use case initialized');

      await ref.read(authenticateUsecaseProvider.future);
      print('Authenticate use case initialized');

      await ref.read(getCurrentUserUsecaseProvider.future);
      print('Get current user use case initialized');

      await ref.read(logoutUsecaseProvider.future);
      print('Logout use case initialized');

      // Initialize Google sign-in use case (optional, may fail if not configured)
      try {
        await ref.read(googleSigninUsecaseProvider.future);
        print('Google sign-in use case initialized');
      } catch (e) {
        print('Google sign-in use case initialization skipped: $e');
      }

      print('All auth providers pre-initialized successfully');
    } catch (e) {
      print('Error pre-initializing auth providers: $e');
      // Continue even if auth providers fail to initialize
      // The login page will handle the error gracefully
    }
  }

  /// Pre-initialize playback providers to prevent delays when user starts playback
  /// This ensures all playback-related providers are ready before user navigates to playback
  Future<void> _initializePlaybackProviders() async {
    try {
      print('Pre-initializing playback providers...');

      // Initialize playback local datasource (depends on database)
      await ref.read(playbackLocalDatasourceProvider.future);
      print('Playback local datasource initialized');

      // Initialize playback repository (depends on datasource)
      await ref.read(playbackRepositoryProvider.future);
      print('Playback repository initialized');

      // Initialize bookmark local datasource (depends on database)
      await ref.read(bookmarkLocalDatasourceProvider.future);
      print('Bookmark local datasource initialized');

      // Initialize bookmark repository (depends on datasource)
      await ref.read(bookmarkRepositoryProvider.future);
      print('Bookmark repository initialized');

      print('All playback providers pre-initialized successfully');
    } catch (e) {
      print('Error pre-initializing playback providers: $e');
      // Continue even if playback providers fail to initialize
      // The playback page will handle the error gracefully
    }
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      // Ensure Supabase client is initialized before accessing it
      await ref.read(supabaseClientProvider.future);
      print('Supabase client ready');

      // Ensure database service is initialized
      final databaseService = await ref.read(databaseServiceProvider.future);
      print('Database service ready');

      // Ensure only one user profile exists in the database
      final userProfileService = await ref.read(
        userProfileServiceProvider.future,
      );
      await userProfileService.ensureSingleUserProfile();
      print('User profile service ready');

      // Check if there's a user in ISAR
      final userProfile = await databaseService.isar.userProfileModels.where().findFirst();

      if (userProfile != null) {
        print('User found in ISAR, verifying with Supabase');
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
              print('User and audiobooks exist, navigating to library');
              if (mounted) {
                unawaited(Navigator.of(context).pushReplacementNamed('/library'));
              }
            } else {
              // User exists but no audiobooks, go to directory selection
              print('User exists but no audiobooks, navigating to directory selection');
              if (mounted) {
                unawaited(
                  Navigator.of(context).pushReplacementNamed('/directory'),
                );
              }
            }
          } else {
            // User doesn't exist in Supabase anymore, redirect to login
            print('User not found in Supabase, navigating to login');
            if (mounted) {
              unawaited(Navigator.of(context).pushReplacementNamed('/auth'));
            }
          }
        } catch (e) {
          // Log the error for debugging
          debugPrint('Error during user verification with Supabase: $e');

          // Error occurred during verification, redirect to login
          if (mounted) {
            unawaited(Navigator.of(context).pushReplacementNamed('/auth'));
          }
        }
      } else {
        // No user in ISAR, redirect to login
        print('No user in ISAR, navigating to login');
        if (mounted) {
          unawaited(Navigator.of(context).pushReplacementNamed('/auth'));
        }
      }
    } catch (e) {
      debugPrint('Error during auth check and navigation: $e');

      // If initialization fails, show login page as fallback
      if (mounted) {
        unawaited(Navigator.of(context).pushReplacementNamed('/auth'));
      }
    }
  }

  void _retryInitialization() {
    setState(() {
      _errorMessage = null;
    });

    _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
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
                Icons.error_outline,
                size: 100,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Initialization Error',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _errorMessage!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _retryInitialization,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: const Text('Retry'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Navigate to auth screen as fallback
                  Navigator.of(context).pushReplacementNamed('/auth');
                },
                child: const Text('Continue as Guest'),
              ),
            ],
          ),
        ),
      );
    }

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
