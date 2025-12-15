# Quick Reference: How the Scanning Flow Works

## The Complete Journey: Directory → Scan → Database → Library

### Step 1: User Opens Directory Selection Screen

**Screen:** `lib/features/directory_selection/presentation/view/directory_selection_screen.dart`

```dart
// Screen is a ConsumerStatefulWidget (has access to Riverpod)
class DirectorySelectionScreen extends ConsumerStatefulWidget {
  // User selects directory via FilePicker
  // Screen shows path in UI
}
```

---

### Step 2: User Presses "Continue" Button

**Trigger:** `_handleContinuePressed()` method

```dart
Future<void> _handleContinuePressed() async {
  final path = _selectedDirectory!;

  // Get the scanning use case from Riverpod
  final scanUseCase = await ref.read(scanLibraryUseCaseProvider.future);

  // Show loading indicator
  ScaffoldMessenger.of(context).showSnackBar(...);

  // Execute the scan
  final result = await scanUseCase.execute(path);

  // Show results
  // Navigate to library if successful
}
```

---

### Step 3: ScanLibraryUseCase Orchestrates the Workflow

**Use Case:** `lib/features/directory_selection/domain/usecases/scan_library_usecase.dart`

**Provider:** `lib/core/provider/providers.dart` → `scanLibraryUseCaseProvider`

```dart
@override
Future<ScanResult> execute(String directoryPath) async {
  final stopwatch = Stopwatch()..start();
  final errors = <String>[];

  try {
    // STEP 1: Scan directory for audio files
    final audioFiles = await extractor.scanDirectoryForAudioFiles(directoryPath);
    // Returns: List<String> of file paths

    // STEP 2: Extract metadata from each file
    final audiobooks = <Audiobook>[];
    for (final filePath in audioFiles) {
      try {
        final audiobook = await extractor.extractMetadata(filePath);
        if (audiobook != null) {
          audiobooks.add(audiobook);
        }
      } catch (e) {
        errors.add('Failed to extract metadata from $filePath: $e');
        // Continue to next file instead of failing
      }
    }

    // STEP 3: Save all successfully extracted audiobooks to database
    if (audiobooks.isNotEmpty) {
      await localDatasource.saveAudiobooks(audiobooks);
    }

    stopwatch.stop();

    // STEP 4: Return results
    return ScanResult(
      scannedFiles: audiobooks.length,
      elapsedTime: stopwatch.elapsed,
      errors: errors,
      totalSize: audiobooks.fold(0, (sum, b) => sum + b.totalSize),
      scanCompletedAt: DateTime.now(),
    );
  } catch (e, stackTrace) {
    // Handle fatal errors
    errors.add('Scan failed: $e');
    errors.add(stackTrace.toString());
    stopwatch.stop();
    return ScanResult(scannedFiles: 0, ...);
  }
}
```

**Dependencies Injected:**
- `MetadataExtractionDatasource extractor` - handles file operations
- `AudiobookLocalDatasource localDatasource` - handles database operations

---

### Step 4a: MetadataExtractionDatasource Extracts Metadata

**Datasource:** `lib/features/directory_selection/data/datasources/metadat_extractor_ds.dart`

**Provider:** `lib/core/provider/providers.dart` → `metadataExtractionDatasourceProvider`

```dart
// 1. Scan directory for audio files
Future<List<String>> scanDirectoryForAudioFiles(String directoryPath) async {
  // Walk directory tree recursively
  // Find files with extensions: .mp3, .m4a, .m4b, .wav, .flac
  // Returns: List of absolute paths to audio files
}

// 2. Extract metadata from a single file
Future<Audiobook?> extractMetadata(String filePath) async {
  // Open file with just_audio
  // Extract duration
  // Parse filename for title/author
  // Extract ID3 tags if present
  // Extract cover art if available
  // Parse chapters if M4B file
  // Returns: Audiobook entity or null if extraction fails
}

// 3. Check if file is accessible
Future<bool> isFileAccessible(String filePath) async {
  // Verify file exists
  // Verify file is readable
  // Returns: true if accessible, false otherwise
}
```

**Responsibility:** File scanning and metadata extraction ONLY
**Does NOT:** Access database, save anything, depend on other datasources

---

### Step 4b: AudiobookLocalDatasource Saves to Database

**Datasource:** `lib/features/library/data/datasources/audiobook_local_ds.dart`

**Provider:** `lib/core/provider/providers.dart` → `audiobookLocalDatasourceProvider`

```dart
// Save audiobooks to Isar database
Future<void> saveAudiobooks(List<Audiobook> audiobooks) async {
  // Convert each Audiobook entity to AudiobookModel
  // Begin Isar write transaction
  // Insert all models into database
  // Commit transaction
  // Throws DatabaseException on failure
}

// Query audiobooks from database
Future<List<Audiobook>> getAudiobooks() async {
  // Query all audiobooks from Isar
  // Convert models to entities
  // Return list
}

// Query by ID
Future<Audiobook?> getAudiobookById(String id) async {
  // Query single audiobook by ID
  // Convert model to entity
  // Return audiobook or null
}
```

**Responsibility:** Database I/O ONLY
**Does NOT:** Extract metadata, check file existence, depend on other datasources

---

### Step 5: Results Returned to Screen

**Result Type:** `ScanResult`

```dart
class ScanResult {
  final int scannedFiles;           // Number of audiobooks found
  final Duration elapsedTime;       // How long scan took
  final List<String> errors;        // Per-file errors (non-fatal)
  final int totalSize;              // Total bytes
  final DateTime scanCompletedAt;   // When scan finished

  bool get hasErrors => errors.isNotEmpty;
  bool get success => !hasErrors;
}
```

**Back in Screen:**
```dart
// After scan completes, result is received
print('Scanned ${result.scannedFiles} files');
print('Errors: ${result.errors}');

// Show user feedback
if (result.success) {
  showSnackBar('Scanned ${result.scannedFiles} files in ${result.elapsedTime.inSeconds}s');
} else {
  showSnackBar('Scan completed with errors. Check logs.');
}

// Navigate to library
if (result.scannedFiles > 0) {
  Navigator.of(context).pushReplacementNamed('/library');
}
```

---

## Dependency Injection Setup

### Provider Hierarchy (in `lib/core/provider/providers.dart`)

```
┌─────────────────────────────────────────────────────┐
│ Bootstrap (lib/bootstrap.dart)                      │
│ - Creates ProviderContainer                         │
│ - Initializes databaseServiceProvider early         │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│ databaseServiceProvider                             │
│ - Initializes Isar database                         │
│ - Returns DatabaseService singleton                 │
└─────────────────────────────────────────────────────┘
                        ↓
        ┌───────────────┴───────────────┐
        ↓                               ↓
┌───────────────────────┐    ┌──────────────────────┐
│ audiobookLocal        │    │ jsonStorageProvider  │
│ DatasourceProvider    │    └──────────────────────┘
│                       │
│ Waits for:            │
│ - DatabaseService OK  │
│ - Isar initialized    │
│ - JsonStorage ready   │
└───────────────────────┘
        ↓
┌───────────────────────────────────────┐
│ scanLibraryUseCaseProvider            │
│                                       │
│ Depends on:                           │
│ - metadataExtractionDatasource        │
│ - audiobookLocalDatasource (ready)    │
│                                       │
│ Provides:                             │
│ - ScanLibraryUseCaseImpl               │
└───────────────────────────────────────┘
```

### Initialization Order Guaranteed

1. **Bootstrap starts** → Creates ProviderContainer
2. **Database init** → Isar opens
3. **Datasources ready** → Have Isar instance
4. **Use case ready** → Has datasources
5. **Screen can use** → Everything is initialized

---

## Error Handling

### Per-File Errors (Non-Fatal)
When extracting metadata from individual files fails, the scan:
- Records the error message
- Continues to next file
- Saves successfully extracted files
- Returns partial results with error list

```dart
errors: [
  'Failed to extract metadata from /path/to/file1.mp3: No ID3 tags found',
  'Failed to extract metadata from /path/to/file2.m4a: Unsupported format',
]
scannedFiles: 13  // Other 13 files were successfully scanned
```

### Fatal Errors
If directory doesn't exist or can't be accessed:
- Entire scan fails
- No files are saved
- Error is reported
- User can retry

```dart
errors: [
  'Scan failed: Directory does not exist: /path/to/nonexistent',
  'Stack trace...'
]
scannedFiles: 0
```

---

## Testing the Integration

### Unit Test Example
```dart
test('ScanLibraryUseCase orchestrates extraction and storage', () async {
  // Mock datasources
  final mockExtractor = MockMetadataExtractionDatasource();
  final mockStorage = MockAudiobookLocalDatasource();

  // Create use case
  final useCase = ScanLibraryUseCaseImpl(
    extractor: mockExtractor,
    localDatasource: mockStorage,
  );

  // Execute
  final result = await useCase.execute('/test/path');

  // Verify
  verify(() => mockExtractor.scanDirectoryForAudioFiles('/test/path')).called(1);
  verify(() => mockStorage.saveAudiobooks(any())).called(1);
  expect(result.scannedFiles, greaterThan(0));
});
```

---

## Common Issues & Solutions

### Issue: Scan doesn't start when Continue pressed
**Cause:** Use case provider not ready
**Solution:** Ensure `databaseServiceProvider` initialized in bootstrap

### Issue: Audiobooks not saved to database
**Cause:** Scan succeeded but `saveAudiobooks()` failed
**Solution:** Check Isar initialization, verify model schemas registered

### Issue: Navigation to library doesn't happen
**Cause:** `result.scannedFiles == 0`
**Solution:** Verify audio files exist and have supported extensions

### Issue: Files not found during scan
**Cause:** Directory path incorrect or no audio files present
**Solution:** Verify path is accessible, use supported extensions

---

## Quick Commands for Debugging

```dart
// Check if use case is ready
final useCase = await ref.read(scanLibraryUseCaseProvider.future);

// Check if database is initialized
final db = await ref.read(databaseServiceProvider.future);

// Check scanned audiobooks
final books = await db.isar.audiobooks.where().findAll();
print('${books.length} audiobooks in database');

// Check specific audiobook
final book = await db.isar.audiobooks.where().first();
print('Title: ${book.title}, Author: ${book.author}');
```

---

**Last Updated:** December 14, 2025
