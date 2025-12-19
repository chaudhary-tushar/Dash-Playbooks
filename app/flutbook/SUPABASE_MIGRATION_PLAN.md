# Supabase Migration Plan for Flutbook

## Executive Summary

This document outlines the complete migration strategy to replace Firebase (Firestore + Auth) with Supabase for the Flutbook audiobook player application. The migration maintains all existing functionality while leveraging Supabase's PostgreSQL-based architecture and real-time capabilities.

## Current Firebase Architecture Analysis

### Firebase Dependencies (from pubspec.yaml)
- `cloud_firestore: ^6.1.0` - Firestore database
- `firebase_auth: ^6.1.2` - Authentication
- `firebase_core: ^4.3.0` - Core Firebase services
- `google_sign_in: ^7.2.0` - Google OAuth

### Current Firebase Usage Patterns

#### 1. Authentication (FirebaseAuthDatasource)
- Email/password authentication
- Google OAuth sign-in
- Anonymous authentication
- User profile management
- Authentication state persistence

#### 2. Data Storage (LibraryRemoteDatasource & PlaybackRemoteDatasource)
- User-specific data isolation via Firestore collections
- Real-time synchronization capabilities
- Metadata storage for audiobooks and playback sessions
- Timestamp-based synchronization

#### 3. Current Configuration (bootstrap.dart)
- Firebase initialization with emulator support
- Platform-specific configuration handling
- Error handling for missing Firebase setup

## Migration Strategy

### Phase 1: Infrastructure Setup

#### 1.1 Add Supabase Dependencies
```yaml
dependencies:
  supabase_flutter: ^2.2.0
  # Remove Firebase dependencies:
  # cloud_firestore: ^6.1.0
  # firebase_auth: ^6.1.2
  # firebase_core: ^4.3.0
  # google_sign_in: ^7.2.0
```

#### 1.2 Environment Configuration
Create environment-specific `.env` files:
- `.env.development`
- `.env.staging`
- `.env.production`

Each containing:
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

#### 1.3 Supabase Project Setup
1. Create Supabase project
2. Set up database schema (see Database Schema section)
3. Configure authentication providers (Email, Google OAuth)
4. Set up Row Level Security (RLS) policies
5. Configure real-time subscriptions

### Phase 2: Database Schema Migration

#### 2.1 Current Firestore Structure
```
users/{userId}/libraries/{audiobookId}
users/{userId}/playback_sessions/{sessionId}
```

#### 2.2 New Supabase Schema
```sql
-- Users table (managed by Supabase Auth)
-- No need to create - handled by auth.users

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
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  INDEX idx_audiobooks_user_id (user_id),
  INDEX idx_audiobooks_created_at (created_at)
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
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  INDEX idx_playback_sessions_user_id (user_id),
  INDEX idx_playback_sessions_audiobook_id (audiobook_id)
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

### Phase 3: Authentication Layer Migration

#### 3.1 Replace FirebaseAuthDatasource
Create `SupabaseAuthDatasource` with equivalent functionality:

```dart
class SupabaseAuthDatasource {
  final SupabaseClient _supabase;

  // Email/password authentication
  Future<AuthResult> signInWithEmailAndPassword(String email, String password);
  Future<AuthResult> signUpWithEmailAndPassword(String email, String password);

  // Google OAuth
  Future<AuthResult> signInWithGoogle();

  // Anonymous authentication
  Future<AuthResult> anonymousSignIn();

  // Sign out
  Future<void> signOut();

  // Get current user
  Future<UserProfile?> getCurrentUser();
}
```

#### 3.2 Authentication State Management
- Replace Firebase Auth state listeners with Supabase auth state
- Maintain existing Riverpod provider structure
- Preserve anonymous user support

### Phase 4: Data Layer Migration

#### 4.1 Replace Remote Datasources
Create Supabase equivalents:

```dart
class SupabaseLibraryDatasource {
  Future<void> uploadAudiobookMetadata(AudiobookModel audiobook);
  Future<List<AudiobookModel>> getAudiobookMetadata();
  Future<void> deleteAudiobookMetadata(String audiobookId);
  Future<void> syncAll();
}

class SupabasePlaybackDatasource {
  Future<void> uploadPlaybackSession(PlaybackSession session);
  Future<List<PlaybackSession>> getPlaybackSessions();
}
```

#### 4.2 Real-time Synchronization
- Leverage Supabase's real-time capabilities for live sync
- Replace Firestore listeners with Supabase real-time subscriptions
- Maintain offline-first approach with local Isar database

### Phase 5: Configuration System

#### 5.1 Runtime Configuration Injection
Create environment-aware configuration system:

```dart
class AppConfig {
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String supabaseServiceRoleKey;
  final bool useEmulator;

  factory AppConfig.fromEnvironment() {
    // Load from .env files based on build flavor
  }
}
```

#### 5.2 Bootstrap Integration
Update `bootstrap.dart` to initialize Supabase instead of Firebase:

```dart
Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  // Initialize Supabase
  final config = AppConfig.fromEnvironment();
  await Supabase.initialize(
    url: config.supabaseUrl,
    anonKey: config.supabaseAnonKey,
  );

  // Continue with existing initialization logic
}
```

### Phase 6: Testing Strategy

#### 6.1 Unit Tests
- Mock Supabase client for datasources
- Test all authentication flows
- Verify data synchronization logic

#### 6.2 Integration Tests
- Test real Supabase instance with test data
- Verify RLS policies work correctly
- Test real-time synchronization

#### 6.3 Migration Testing
- Test data migration from Firebase to Supabase
- Verify no data loss during migration
- Test rollback scenarios

## Implementation Timeline

### Week 1: Foundation
- [ ] Set up Supabase project and database schema
- [ ] Create environment configuration system
- [ ] Add Supabase dependencies and remove Firebase

### Week 2: Authentication
- [ ] Implement SupabaseAuthDatasource
- [ ] Update authentication providers
- [ ] Test all auth flows

### Week 3: Data Layer
- [ ] Implement Supabase datasources
- [ ] Update repository implementations
- [ ] Test data synchronization

### Week 4: Integration & Testing
- [ ] Update bootstrap and configuration
- [ ] Comprehensive testing
- [ ] Performance optimization
- [ ] Documentation updates

## Risk Mitigation

### Data Migration Risks
- **Risk**: Data loss during migration
- **Mitigation**: Create backup of all Firebase data, implement gradual migration with dual-write capability

### Performance Risks
- **Risk**: Supabase queries slower than Firestore
- **Mitigation**: Optimize database schema, add proper indexes, use connection pooling

### Authentication Risks
- **Risk**: User accounts not properly migrated
- **Mitigation**: Use Supabase's Firebase migration tools, maintain user experience continuity

## Benefits of Migration

1. **Cost Efficiency**: Supabase offers more generous free tiers and predictable pricing
2. **PostgreSQL Power**: Full SQL capabilities, complex queries, and relationships
3. **Real-time**: Built-in real-time subscriptions without additional setup
4. **Open Source**: No vendor lock-in, self-hosting options
5. **Simplified Architecture**: Single platform for auth, database, and storage

## Rollback Plan

1. **Feature Flags**: Implement feature flags for Firebase/Supabase switching
2. **Dual Implementation**: Maintain both Firebase and Supabase implementations during transition
3. **Gradual Migration**: Migrate features incrementally with ability to rollback
4. **Data Backup**: Maintain Firebase data backup for 30 days post-migration

## Success Criteria

- [ ] All authentication flows work identically to current Firebase implementation
- [ ] Data synchronization maintains real-time capabilities
- [ ] Performance matches or exceeds current Firebase implementation
- [ ] All existing tests pass with Supabase implementation
- [ ] No data loss during migration
- [ ] Users experience zero downtime during migration

## Next Steps

1. Review and approve this migration plan
2. Set up Supabase project and development environment
3. Begin Phase 1 implementation
4. Establish regular progress reviews and testing milestones