# Flutbook Implementation Plan - UI/UX Improvements

## Executive Summary

This document outlines the implementation plan for fixing 5 critical UI/UX issues in the Flutbook audiobook player app, plus creating summary documentation.

## Project Status (from Documentation)

- **MVP Completion**: 73% (24/33 tasks complete)
- **Post-MVP Phase 6**: 6/6 tasks COMPLETE ✅
- **Post-MVP Phase 7**: 6/6 tasks COMPLETE ✅
- **Build Status**: No errors
- **Test Coverage**: 80%+ (core features)

## Issues to Fix

### Issue 1: Playback Always Starts from Beginning
**Problem**: When resuming playback, the app starts from 0:00 instead of the last saved position.

**Root Cause Analysis**:
- `PlaybackRepositoryImpl` has `getLastPlayedPosition()` and `getPlaybackSession()` methods
- `PlaybackSession` entity has `currentPosition` field
- The playback provider calls `setCurrentAudiobook()` which should load saved position
- **Issue**: The saved position may not be properly restored when starting playback

**Files to Modify**:
- `lib/features/player/presentation/providers/playback_provider.dart`
- `lib/features/player/data/repositories/playback_repository_impl.dart`

**Solution**:
1. Ensure `setCurrentAudiobook()` loads saved position from repository
2. Restore position when audio source is loaded
3. Save position periodically during playback
4. Save position when playback is paused/stopped

---

### Issue 2: Reading List Always Empty
**Problem**: The reading list shows no books even when playback has occurred.

**Root Cause Analysis**:
- `Audiobook` entity has `lastPlayedAt` field but no `currentPosition` field
- `LibraryRepositoryImpl._calculateProgress()` calculates progress based on `lastPlayedAt` (time since last played)
- This is incorrect - it should calculate based on actual playback progress (currentPosition / duration)
- The library screen filters books with `lastPlayedAt != null` for "reading" status

**Files to Modify**:
- `lib/features/library/domain/entities/audiobook.dart` - Add `currentPosition` field
- `lib/features/library/data/repositories/library_repository_impl.dart` - Fix progress calculation
- `lib/features/library/presentation/views/library_screen.dart` - Fix reading list filter

**Solution**:
1. Add `currentPosition` field to `Audiobook` entity
2. Update `LibraryRepositoryImpl._calculateProgress()` to use `currentPosition / duration`
3. Update library screen to filter books with `currentPosition > 0` for "reading" status
4. Ensure playback saves position to audiobook entity

---

### Issue 3: Library Screen Sorting Options
**Problem**: Library screen lacks sorting by Name, Progress, and Length with ascending/descending options.

**Root Cause Analysis**:
- `LibraryState` already has `sortBy`, `sortAscending`, `filter` fields
- `LibraryRepositoryImpl.getAudiobooks()` supports sorting by title, author, lastPlayed, dateAdded, progress
- **Missing**: Sorting by duration (length) and ascending/descending toggle in UI

**Files to Modify**:
- `lib/features/library/presentation/views/library_screen.dart` - Add sorting UI
- `lib/features/library/presentation/providers/library_state.dart` - Add duration sort option

**Solution**:
1. Add 'duration' option to sort dropdown
2. Add ascending/descending toggle button
3. Update sort logic to handle duration sorting
4. Update UI to show current sort direction

---

### Issue 4: Cover Art Icons from Metadata
**Problem**: Audiobook cards show placeholder icons instead of cover art from metadata.

**Root Cause Analysis**:
- `MetadataExtractionDatasource._extractCoverArt()` currently returns null for all files
- The method has TODO comments about using a metadata library
- `Audiobook` entity has `coverArtPath` field but it's never populated

**Files to Modify**:
- `lib/features/directory_selection/data/datasources/metadat_extractor_ds.dart` - Implement cover art extraction
- `pubspec.yaml` - Add metadata extraction package (e.g., `audio_tags` or `id3`)

**Solution**:
1. Add metadata extraction package to pubspec.yaml
2. Implement `_extractCoverArt()` to extract cover art from audio files
3. Save cover art to temporary file and return path
4. Handle cases where no cover art exists (return null)

---

### Issue 5: Background Metadata Extraction
**Problem**: App blocks UI during metadata extraction; user can't navigate to library until scan completes.

**Root Cause Analysis**:
- `ScanLibraryUseCase.execute()` is synchronous and blocks UI
- Directory selection screen waits for scan to complete before navigating
- No progress reporting during scan

**Files to Modify**:
- `lib/features/directory_selection/domain/usecases/scan_library_usecase.dart` - Make async with progress
- `lib/features/directory_selection/presentation/view/directory_selection_screen.dart` - Navigate immediately
- `lib/features/library/presentation/views/library_screen.dart` - Show loading state

**Solution**:
1. Make `ScanLibraryUseCase.execute()` return a Stream of progress
2. Navigate to library screen immediately after starting scan
3. Show loading indicator on library screen while scan is in progress
4. Update library screen as new books are discovered

---

### Issue 6: Summary Documentation
**Problem**: Need to document all improvements made.

**Files to Create**:
- `flutbook/documentation/IMPROVEMENTS_SUMMARY.md`

**Solution**:
1. Document each issue and its fix
2. Include before/after comparisons
3. List all files modified
4. Include testing instructions

---

## Implementation Order

### Phase 1: Core Data Model Updates (Issue 2)
1. Add `currentPosition` field to `Audiobook` entity
2. Update Isar schema for audiobook model
3. Update local datasource for position storage
4. Update repository with position methods

### Phase 2: Playback Resume (Issue 1)
1. Update playback provider to load saved position
2. Update playback repository to save position
3. Ensure position is restored when audio loads
4. Add periodic position saving during playback

### Phase 3: Library Sorting (Issue 3)
1. Add duration sort option to library state
2. Update sort logic in repository
3. Add sorting UI to library screen
4. Add ascending/descending toggle

### Phase 4: Cover Art (Issue 4)
1. Add metadata extraction package
2. Implement cover art extraction
3. Update audiobook card to show cover art
4. Handle missing cover art gracefully

### Phase 5: Background Scanning (Issue 5)
1. Make scan use case return progress stream
2. Update directory selection screen to navigate immediately
3. Add loading state to library screen
4. Update library screen as scan progresses

### Phase 6: Documentation (Issue 6)
1. Create improvements summary document
2. Document all changes made
3. Include testing instructions

---


## Files to Modify Summary

### Domain Layer
- `lib/features/library/domain/entities/audiobook.dart` - Add currentPosition field
- `lib/features/player/domain/entities/playback_session.dart` - Already has currentPosition

### Data Layer
- `lib/features/library/data/repositories/library_repository_impl.dart` - Fix progress calculation, add duration sort
- `lib/features/player/data/repositories/playback_repository_impl.dart` - Ensure position save/restore
- `lib/features/directory_selection/data/datasources/metadat_extractor_ds.dart` - Implement cover art extraction

### Presentation Layer
- `lib/features/library/presentation/views/library_screen.dart` - Add sorting UI, loading state
- `lib/features/library/presentation/providers/library_state.dart` - Add duration sort option
- `lib/features/player/presentation/providers/playback_provider.dart` - Load saved position
- `lib/features/directory_selection/presentation/view/directory_selection_screen.dart` - Navigate immediately

### Configuration
- `pubspec.yaml` - Add metadata extraction package

### Documentation
- `flutbook/documentation/IMPROVEMENTS_SUMMARY.md` - New file

---

## Next Steps

1. Start with Issue 2 (Reading List) as it requires data model changes
2. Then Issue 1 (Playback Resume) as it depends on position tracking
3. Then Issue 3 (Sorting) as it's UI-only
4. Then Issue 4 (Cover Art) as it requires new package
5. Then Issue 5 (Background Scanning) as it requires async changes
6. Finally Issue 6 (Documentation)

---

## Notes

- All changes should maintain backward compatibility
- Existing tests should continue to pass
- New tests should be added for new functionality
- Code should follow existing patterns in the codebase
- Use Riverpod for state management
- Use Isar for local database
- Follow clean architecture principles

---

**Created**: March 15, 2026
**Status**: Ready for Implementation
