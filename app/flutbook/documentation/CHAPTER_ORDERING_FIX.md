# 🔧 Audiobook Chapter/Track Ordering Fix

## Problem Description

When clicking on an audiobook to start playing, the files/tracks were displayed in a jumbled order instead of being sorted by:
1. Track number (e.g., Track 01, Track 02, etc.)
2. Disc number (for multi-disc audiobooks)
3. File name/numbering

This made it difficult to follow the audiobook in the correct sequence.

## Root Cause Analysis

The issue occurred in two places:

### 1. Audiobook Grouping (Multi-File Audiobooks)
**File:** `lib/features/library/domain/services/audiobook_grouping_service.dart`

When audiobooks were grouped together (either by metadata or directory), the individual files within each group were not sorted. They appeared in the order they were added to the group, which was essentially random based on file system enumeration order.

### 2. Chapter Sorting (Within Single Files)
**File:** `lib/features/library/domain/entities/audiobook.dart`

When chapters were extracted from audio files (especially M4B files with chapter markers), they were stored in the order they appeared in the file metadata, but not explicitly sorted by start time.

## Solution Implemented

### 1. Added Track-Based Sorting for Audiobook Groups

**File Modified:** `lib/features/library/domain/services/audiobook_grouping_service.dart`

Added three new methods:

#### `_sortAudiobooksByTrack()`
Sorts audiobooks within each group by:
1. **Disc number** (if present) - Multi-disc audiobooks are sorted by disc first
2. **Track number** (if present) - Then by track within each disc
3. **Filename** (fallback) - If no track/disc numbers found, sorts alphabetically by filename

#### `_extractTrackNumber()`
Extracts track numbers from titles or filenames using regex patterns:
- `Track 01`, `track 1`, `TRACK 001`
- `01 - Title`, `001 - Title`
- `01.Title`, `001.Title`
- `01 Title`

#### `_extractDiscNumber()`
Extracts disc numbers from titles or filenames using regex patterns:
- `Disc 1`, `disc 01`, `DISC 1`
- `CD 1`, `cd 01`
- `Disk 1`, `disk 01`

### 2. Added Chapter Sorting by Start Time

**File Modified:** `lib/features/library/domain/entities/audiobook.dart`

Updated the `fromMap()` factory constructor to sort chapters by their `startTime`:

```dart
final chapters = List<Chapter>.from(
  (map['chapters'] as List<dynamic>).map<Chapter>(
    (x) => Chapter.fromMap(x as Map<String, dynamic>),
  ),
)..sort((a, b) => a.startTime.compareTo(b.startTime));
```

This ensures chapters are always displayed in chronological order regardless of how they were stored in the metadata.

## Supported Track Number Formats

The fix recognizes the following track number formats:

### In Titles:
- `Track 01 - Chapter Title`
- `01 - Chapter Title`
- `001 - Chapter Title`
- `01. Chapter Title`
- `Chapter 01: Title`

### In Filenames:
- `01.mp3`
- `01 - Title.mp3`
- `Track 01.mp3`
- `01_Title.mp3`
- `CD01-Track01.mp3`

### Disc Numbers:
- `Disc 1 Track 01`
- `CD 01 - Track 01`
- `Disk 1 - Track 01`

## Examples

### Before Fix:
```
Audiobook Group: "Harry Potter"
├─ File_07.mp3  ❌
├─ File_01.mp3  ❌
├─ File_03.mp3  ❌
├─ File_02.mp3  ❌
└─ File_05.mp3  ❌
```

### After Fix:
```
Audiobook Group: "Harry Potter"
├─ 01 - Introduction.mp3  ✅
├─ 02 - Chapter 1.mp3     ✅
├─ 03 - Chapter 2.mp3     ✅
├─ 05 - Chapter 3.mp3     ✅
└─ 07 - Chapter 4.mp3     ✅
```

### Multi-Disc Example:
```
Audiobook Group: "Lord of the Rings"
├─ Disc 1/
│  ├─ 01 - Prologue.mp3   ✅
│  └─ 02 - Chapter 1.mp3  ✅
├─ Disc 2/
│  ├─ 01 - Chapter 5.mp3  ✅
│  └─ 02 - Chapter 6.mp3  ✅
└─ Disc 3/
   ├─ 01 - Chapter 9.mp3  ✅
   └─ 02 - Epilogue.mp3   ✅
```

## Files Modified

1. **`lib/features/library/domain/services/audiobook_grouping_service.dart`**
   - Added `_sortAudiobooksByTrack()` method
   - Added `_extractTrackNumber()` method
   - Added `_extractDiscNumber()` method
   - Updated `_groupByMetadata()` to sort audiobooks
   - Updated `_groupByDirectory()` to sort audiobooks

2. **`lib/features/library/domain/entities/audiobook.dart`**
   - Updated `fromMap()` to sort chapters by `startTime`

## Testing Instructions

### Test 1: Single Directory with Numbered Files
1. Create a directory with audio files named: `03.mp3`, `01.mp3`, `02.mp3`
2. Scan the directory
3. Open the audiobook group
4. **Expected:** Files appear in order: 01, 02, 03

### Test 2: Multi-Disc Audiobook
1. Create directories: `Disc 1/`, `Disc 2/`
2. Add files: `Disc 1/01.mp3`, `Disc 1/02.mp3`, `Disc 2/01.mp3`, `Disc 2/02.mp3`
3. Scan the directories
4. Open the audiobook group
5. **Expected:** Disc 1 tracks appear before Disc 2 tracks

### Test 3: Files with "Track" Prefix
1. Create files: `Track 05.mp3`, `Track 01.mp3`, `Track 03.mp3`
2. Scan the directory
3. Open the audiobook
4. **Expected:** Files appear in order: Track 01, Track 03, Track 05

### Test 4: M4B with Chapters
1. Load an M4B file with chapter markers
2. Open the audiobook
3. View the chapters list
4. **Expected:** Chapters appear in chronological order by start time

## Algorithm Details

### Sorting Priority:
```
1. Extract disc number (if present)
   ↓
2. Extract track number (if present)
   ↓
3. Compare by disc first
   ↓
4. Compare by track within same disc
   ↓
5. Fallback to filename comparison
```

### Regex Patterns Used:

**Track Number:**
```dart
r'\btrack\s*(\d+)\b'       // "Track 01", "track 1"
r'^(\d+)[-_\s]+'           // "01 -", "01_", "01 "
r'^(\d+)\.'                // "01."
r'\b(\d+)\b[-_\s]+track\b' // "01-track"
```

**Disc Number:**
```dart
r'\b(?:disc|cd|disk)\s*(\d+)\b'  // "Disc 1", "CD 01", "Disk 1"
r'\b(\d+)\s*(?:disc|cd|disk)\b'  // "1 Disc", "01 CD"
```

## Performance Considerations

- Sorting happens during grouping, not during UI rendering
- Regex patterns are compiled once per sort operation
- For typical audiobooks (10-50 files), performance impact is negligible
- For very large collections (1000+ files), consider caching sort results

## Edge Cases Handled

| Edge Case | Handling |
|-----------|----------|
| No track numbers | Falls back to filename sorting |
| Mixed formats | Each file is parsed independently |
| Missing disc numbers | Treated as disc 0 (single disc) |
| Duplicate track numbers | Maintains original order (stable sort) |
| Non-numeric titles | Falls back to alphabetical sorting |
| Empty track/disc numbers | Treated as null, uses fallback |

## Future Enhancements

1. **Metadata Extraction:** Extract actual track numbers from ID3 tags or MP4 metadata
2. **Series Information:** Better handling of book series (Book 1, Book 2, etc.)
3. **User Preferences:** Allow users to choose sorting method
4. **Custom Sort Order:** Let users manually reorder files
5. **Persistent Sorting:** Cache sort results for faster loading

---

**Date:** March 15, 2026  
**Fixed By:** AI Assistant  
**Status:** ✅ Complete - Ready for Testing

**Related Documentation:**
- `PLAYBACK_FIX.md` - Audio playback initialization fix
- `PLAYBACK_FIX_2.md` - Playback initialization flow fix
- `VERIFICATION_REPORT.md` - Phase 6 & 7 implementation verification
