# Supabase Migration Guide for Flutbook

## Overview

This guide provides step-by-step instructions for migrating the Flutbook application from Firebase to Supabase. The migration maintains all existing functionality while leveraging Supabase's PostgreSQL-based architecture.

## Prerequisites

Before starting the migration:

1. **Supabase Account**: Create an account at [supabase.com](https://supabase.com)
2. **Project Setup**: Create a new Supabase project
3. **Database Schema**: Set up the database schema (see Database Setup section)
4. **Environment Variables**: Prepare your environment configuration

## Migration Steps

### Step 1: Database Setup

#### 1.1 Create Database Schema

Execute the following SQL in your Supabase SQL Editor to create the necessary tables:

```sql
-- Audiobooks table
CREATE TABLE audiobooks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  author TEXT,
  album TEXT,
  cover_art_path TEXT,
  duration_ms INTEGER,
  file_path TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_played_at TIMESTAMP WITH TIME ZONE,
  completed BOOLEAN DEFAULT FALSE,
  total_size INTEGER,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Playback sessions table
CREATE TABLE playback_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  audiobook_id UUID REFERENCES audiobooks(id) ON DELETE CASCADE,
  current_position_ms INTEGER DEFAULT 0,
  playback_speed DECIMAL(3,2) DEFAULT 1.0,
  is_playing BOOLEAN DEFAULT FALSE,
  last_played_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  sleep_timer_active BOOLEAN DEFAULT FALSE,
  sleep_timer_duration_ms INTEGER,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE audiobooks ENABLE ROW LEVEL SECURITY;
ALTER TABLE playback_sessions ENABLE ROW LEVEL SECURITY;

-- Policies for user data isolation
CREATE POLICY "Users can view own audiobooks" ON audiobooks
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view own playback sessions" ON playback_sessions
  FOR ALL USING (auth.uid() = user_id);
```

#### 1.2 Configure Authentication

1. Go to **Authentication** → **Providers** in your Supabase dashboard
2. Enable **Email** and **Google** authentication
3. Configure Google OAuth credentials if using Google sign-in

### Step 2: Environment Configuration

#### 2.1 Create Environment Files

Create the following environment files in your project root:

**`.env.development`** (for development):
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-development-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-development-service-role-key
ENVIRONMENT=development
DEBUG=true
ENABLE_REAL_TIME_SYNC=true
ENABLE_OFFLINE_MODE=true
ENABLE_ANALYTICS=false
```

**`.env.staging`** (for staging):
```
SUPABASE_URL=https://your-staging-project.supabase.co
SUPABASE_ANON_KEY=your-staging-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-staging-service-role-key
ENVIRONMENT=staging
DEBUG=false
ENABLE_REAL_TIME_SYNC=true
ENABLE_OFFLINE_MODE=true
ENABLE_ANALYTICS=true
```

**`.env.production`** (for production):
```
SUPABASE_URL=https://your-production-project.supabase.co
SUPABASE_ANON_KEY=your-production-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-production-service-role-key
ENVIRONMENT=production
DEBUG=false
ENABLE_REAL_TIME_SYNC=true
ENABLE_OFFLINE_MODE=true
ENABLE_ANALYTICS=true
```

#### 2.2 Update Dependencies

Update your `pubspec.yaml` to replace Firebase dependencies with Supabase:

```yaml
dependencies:
  # Remove Firebase dependencies:
  # cloud_firestore: ^6.1.0
  # firebase_auth: ^6.1.2
  # firebase_core: ^4.3.0
  # google_sign_in: ^7.2.0

  # Add Supabase dependencies:
  supabase_flutter: ^2.2.0
  flutter_dotenv: ^5.1.0
```

### Step 3: Code Migration

#### 3.1 Update Bootstrap Configuration

Replace the Firebase initialization in `lib/bootstrap.dart` with Supabase initialization:

```dart
// Remove Firebase imports
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutbook/firebase_options.dart';

// Add Supabase and config imports
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutbook/core/config/app_config.dart';

// Replace Firebase initialization with:
Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  // ... existing code ...

  // Initialize application configuration
  try {
    final configProvider = ConfigProvider();
    await configProvider.initialize();
    print('App configuration loaded successfully');
    print(configProvider.config.getSummary());
  } catch (e) {
    print('Warning: Configuration initialization failed in bootstrap: $e');
    print('Continuing app startup with default configuration...');
  }

  // ... rest of bootstrap code ...
}
```

#### 3.2 Replace Authentication Datasource

Replace `FirebaseAuthDatasource` with `SupabaseAuthDatasource`:

1. **Create the new datasource** (already created):
   - `lib/features/auth/data/datasources/supabase_auth_datasource.dart`

2. **Update repository** to use the new datasource:
   - Update `UserRepositoryImpl` to use `SupabaseAuthDatasource` instead of `FirebaseAuthDatasource`

3. **Update providers** in `lib/core/provider/providers.dart`:
   ```dart
   // Replace:
   // final firebaseAuthDatasourceProvider = Provider<FirebaseAuthDatasource>((ref) {
   //   return FirebaseAuthDatasource();
   // });

   // With:
   final supabaseAuthDatasourceProvider = Provider<SupabaseAuthDatasource>((ref) {
     final supabase = ref.watch(supabaseClientProvider);
     final configProvider = ref.watch(configProviderProvider);
     return SupabaseAuthDatasource(
       supabase: supabase,
       configProvider: configProvider,
     );
   });
   ```

#### 3.3 Replace Data Datasources

Replace Firebase datasources with Supabase equivalents:

1. **Create new datasources** (already created):
   - `lib/features/library/data/datasources/remote/supabase_library_sync.dart`
   - `lib/features/player/data/datasources/remote/supabase_playback_sync.dart`

2. **Update repositories** to use the new datasources:
   - Update `LibraryRepositoryImpl` to use `SupabaseLibraryDatasource`
   - Update `PlaybackRepositoryImpl` to use `SupabasePlaybackDatasource`

3. **Update providers** in `lib/core/provider/providers.dart`:
   ```dart
   // Replace Firebase datasources with Supabase equivalents
   final libraryRemoteDatasourceProvider = Provider<SupabaseLibraryDatasource>(
     (ref) {
       final supabase = ref.watch(supabaseClientProvider);
       final configProvider = ref.watch(configProviderProvider);
       return SupabaseLibraryDatasource(
         supabase: supabase,
         configProvider: configProvider,
       );
     },
   );

   final playbackRemoteDatasourceProvider = Provider<SupabasePlaybackDatasource>(
     (ref) {
       final supabase = ref.watch(supabaseClientProvider);
       final configProvider = ref.watch(configProviderProvider);
       return SupabasePlaybackDatasource(
         supabase: supabase,
         configProvider: configProvider,
       );
     },
   );
   ```

### Step 4: Testing

#### 4.1 Run Tests

Execute the test suite to ensure all functionality works correctly:

```bash
# Run all tests
flutter test

# Run specific Supabase tests
flutter test test/features/auth/data/datasources/supabase_auth_datasource_test.dart

# Run with coverage
flutter test --coverage
```

#### 4.2 Manual Testing

Test the following scenarios:

1. **Authentication**:
   - Email/password sign-up and sign-in
   - Google OAuth sign-in
   - Anonymous authentication
   - Logout functionality

2. **Library Management**:
   - Adding audiobooks
   - Viewing library
   - Searching and filtering
   - Updating audiobook metadata

3. **Playback**:
   - Starting playback
   - Seeking through audiobooks
   - Updating playback position
   - Sleep timer functionality

### Step 5: Build and Deploy

#### 5.1 Build for Different Environments

```bash
# Development build
flutter run --flavor development --target lib/main_development.dart

# Staging build
flutter run --flavor staging --target lib/main_staging.dart

# Production build
flutter run --flavor production --target lib/main_production.dart
```

#### 5.2 Production Deployment

1. **Update environment variables** in your deployment environment
2. **Build the application**:
   ```bash
   flutter build apk --release
   # or
   flutter build ios --release
   ```
3. **Deploy to stores** following standard procedures

## Post-Migration Tasks

### 1. Data Migration (Optional)

If you need to migrate existing Firebase data to Supabase:

1. **Export Firebase data** using Firebase Admin SDK
2. **Transform data** to match Supabase schema
3. **Import data** into Supabase using bulk insert operations
4. **Update user accounts** to use Supabase Auth

### 2. Monitoring and Optimization

1. **Set up monitoring** for your Supabase project
2. **Monitor performance** and optimize queries as needed
3. **Review RLS policies** to ensure data security
4. **Optimize database indexes** for better performance

### 3. Cleanup

1. **Remove Firebase dependencies** completely from `pubspec.yaml`
2. **Delete Firebase configuration files**:
   - `lib/firebase_options.dart`
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
3. **Remove Firebase-related code** from the codebase
4. **Update documentation** to reflect the new architecture

## Troubleshooting

### Common Issues

1. **Authentication Errors**:
   - Verify Supabase project URL and keys
   - Check authentication provider configuration
   - Ensure RLS policies are correctly set

2. **Database Connection Errors**:
   - Verify network connectivity
   - Check Supabase project status
   - Review database permissions

3. **Real-time Sync Issues**:
   - Ensure real-time subscriptions are enabled
   - Check network stability
   - Verify user authentication state

### Getting Help

- **Supabase Documentation**: [https://supabase.com/docs](https://supabase.com/docs)
- **Supabase Community**: [https://supabase.com/community](https://supabase.com/community)
- **GitHub Issues**: Report issues on the Supabase Flutter repository

## Benefits of Migration

After completing the migration, you'll enjoy:

1. **Cost Savings**: More predictable pricing with generous free tiers
2. **Better Performance**: PostgreSQL's powerful query capabilities
3. **Real-time Features**: Built-in real-time subscriptions
4. **Open Source**: No vendor lock-in, self-hosting options
5. **Simplified Architecture**: Single platform for auth, database, and storage

## Conclusion

This migration guide provides a comprehensive approach to replacing Firebase with Supabase in your Flutbook application. The new architecture maintains all existing functionality while providing additional benefits and flexibility.

Remember to test thoroughly in each environment and monitor performance after deployment. The migration should be seamless for end users, with no disruption to their audiobook library or playback progress.