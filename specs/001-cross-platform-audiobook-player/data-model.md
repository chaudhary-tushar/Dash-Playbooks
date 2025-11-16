# Data Model: Cross-Platform Audiobook Player

## Entities

### Audiobook
- **id**: String (unique identifier, typically file path hash)
- **title**: String (from metadata or filename)
- **author**: String (from metadata or empty)
- **album**: String (from metadata or empty)
- **coverArtPath**: String? (path to cover art file or URL)
- **duration**: Duration (total duration in milliseconds)
- **filePath**: String (absolute path to audio file)
- **chapters**: List<Chapter> (list of chapter objects if available)
- **createdAt**: DateTime (when added to library)
- **lastPlayedAt**: DateTime? (last playback time)
- **completed**: bool (true if playback reached 95%+)
- **totalSize**: int (file size in bytes)

### Chapter
- **id**: String (unique identifier)
- **title**: String (chapter title)
- **startTime**: Duration (start time from beginning of audiobook)
- **endTime**: Duration (end time of chapter)

### PlaybackSession
- **audiobookId**: String (reference to audiobook)
- **currentPosition**: Duration (current playback position)
- **playbackSpeed**: double (playback speed 0.5x-3.0x)
- **isPlaying**: bool (whether currently playing)
- **lastPlayedAt**: DateTime (timestamp of last update)
- **sleepTimerActive**: bool (whether sleep timer is active)
- **sleepTimerDuration**: Duration? (remaining time for sleep timer)

### UserProfile
- **id**: String (Firebase user ID)
- **email**: String (user email)
- **displayName**: String? (user's display name)
- **authMethod**: String (email_password, google_oauth, etc.)
- **syncEnabled**: bool (whether sync is enabled)
- **lastSyncAt**: DateTime? (last successful sync timestamp)
- **localLibraryPath**: String (path to local audiobook directory)

### Library
- **id**: String (unique identifier)
- **name**: String (library name)
- **path**: String (directory path)
- **audiobooks**: List<Audiobook> (collection of audiobooks)
- **lastScanAt**: DateTime (last time library was scanned)
- **totalAudiobooks**: int (count of audiobooks)
- **totalDuration**: Duration (total duration of all audiobooks)

## Isar Schema Considerations

### Audiobook Isar Collection
- Uses Isar ID for primary key
- Indexed fields: `title` (for search), `author` (for browsing), `completed` (for filtering), `lastPlayedAt` (for sorting)
- Isar inspector: Enable for debugging and development
- Compound indexes: Consider combinations like (author, completed) for efficient browsing
- Ignores: computed properties that can be derived from other fields
- **CRITICAL**: All specified indexes must be implemented to meet performance requirements (1000+ files in < 3 seconds)

### PlaybackSession Isar Collection
- Uses audiobookId as primary key to ensure one session per audiobook
- Indexed: `lastPlayedAt` for sorting by recent activity
- Isar inspector: Enable for debugging playback state
- Includes Isar-specific metadata for efficient querying

### UserProfile Isar Collection
- For anonymous users, generates unique local ID
- Stores sync preferences and local settings
- Indexed: `id` (for quick access), `syncEnabled` (for sync operations)
- Isar inspector: Enable for debugging user state

### Library Isar Collection
- Stores metadata about user's audiobook directories
- Tracks last scan time for efficient updates
- Indexed: `path` (for quick directory lookup), `lastScanAt` (for update management)
- Isar inspector: Enable for debugging library management

## Relationships

- **UserProfile** has many **Library** instances (1:M)
- **Library** has many **Audiobook** instances (1:M)
- **Audiobook** has many **Chapter** instances (1:M)
- **UserProfile** has one **PlaybackSession** per audiobook (1:1 per audiobook)

## Validation Rules

### Audiobook
- title must not be empty
- filePath must be valid and accessible
- duration must be positive
- coverArtPath must be valid image format if provided

### Chapter
- startTime must be less than endTime
- startTime and endTime must be within audiobook duration
- chapter titles should be unique within audiobook

### PlaybackSession
- currentPosition must be less than audiobook duration
- playbackSpeed must be between 0.5 and 3.0
- sleepTimerDuration must be positive if sleepTimerActive is true

### UserProfile
- email must be valid email format
- authMethod must be one of allowed values
- localLibraryPath must be valid directory

## State Transitions

### Audiobook States
- `not_started` (default)
- `in_progress` (when first played)
- `completed` (when >95% played)
- `abandoned` (user manually marked as not interested)

### PlaybackSession States
- `paused` (default when session starts)
- `playing` (when actively playing)
- `stopped` (when playback ends)
- `sleep_timer_active` (when sleep timer is enabled)

### UserProfile States
- `anonymous` (no account, local only)
- `authenticated` (logged in, sync enabled)
- `sync_pending` (when offline changes need sync)
- `sync_conflict` (when sync conflicts detected)

## Performance Considerations

### Isar Query Optimization
- Use indexes on frequently queried fields: title, author, completed, lastPlayedAt
- Implement lazy loading for large libraries
- Batch operations where possible
- Consider pagination for very large collections (>1000 items)
- Optimize for the primary use cases: search, filter, sort audiobooks
- **CRITICAL**: Schema and indexes must support library scan performance goal of 1000+ files in < 3 seconds

### Memory Management
- Efficient loading of cover art (scaled appropriately)
- Lazy loading of chapter data
- Proper disposal of Isar instances
- Cache frequently accessed data appropriately

## Error Handling Requirements

All entities and operations must support proper error handling for the edge cases specified in the feature specification:
- Large file handling (>10GB audiobooks)
- Missing or corrupted metadata
- Permission issues for file access
- Network unavailability during sync
- File moved/deleted after scanning
- Insufficient storage space
- Corrupted audio files during playback
- Error handling must provide clear, user-friendly messages as required by constitution (no raw stack traces in UI)