How to View Isar Database Content

This document explains different methods to inspect the content of your Isar database in the Flutbook app.

Method 1: Using the Database Inspector (Recommended for Debugging)

The project includes a DatabaseInspector class that allows you to programmatically inspect the database content:

```dart
import 'package:flutbook/debug/database_inspector.dart';

// In your debug code or widget:
final databaseInspector = DatabaseInspector(databaseService);
await databaseInspector.printAllContent();
```

This will print all database content to the console in a readable format.

Method 2: Using Isar Inspector (For Development)

For more visual inspection during development, you can use the Isar Inspector:

1. Add to your pubspec.yaml:
```yaml
dependencies:
  isar_inspector: ^3.0.0  # Make sure this matches your Isar version
```

2. In your debug code:
```dart
import 'package:isar_inspector/isar_inspector.dart';

// In your database initialization code (only in debug mode):
if (kDebugMode) {
  await isarInspector(yourIsarInstance);
}
```

This will open a web-based inspector interface.

Method 3: Direct Queries in Code

You can directly query the database in your code:

```dart
// Get all audiobooks
final audiobooks = await isar.audiobookModels.where().findAll();

// Get specific audiobook by ID
final audiobook = await isar.audiobookModels.get(someId);

// Get playback sessions for a specific audiobook
final sessions = await isar.playbackSessionModels
  .filter()
  .audiobookIdEqualTo('someAudiobookId')
  .findAll();

// Count records
final count = await isar.audiobookModels.where().count();
```

Method 4: Using Flutter DevTools

1. Run your app with flutter run
2. Open Flutter DevTools (flutter devtools)
3. Use the "Inspector" tab to examine your app's state
4. You can also use the "Debug Paint" and other tools to understand your app's behavior.

Database Collections in Flutbook

The Isar database in Flutbook contains these collections:

1. **AudiobookModel** - Stores audiobook metadata (title, author, path, etc.)
2. **PlaybackSessionModel** - Stores current playback session information
3. **PlaybackHistoryModel** - Stores playback history and positions
4. **UserProfileModel** - Stores user profile information

Example Usage in Widget for Debugging

```dart
class DebugDatabaseView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Database Debug')),
      body: FutureBuilder(
        future: ref.read(databaseServiceProvider).init(), // Ensure DB is initialized
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final inspector = DatabaseInspector(
                      ref.read(databaseServiceProvider),
                    );
                    await inspector.printAllContent();
                    print('Check the console for database content');
                  },
                  child: Text('Inspect Database'),
                ),
                // Add more debug controls as needed
              ],
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
```

Important Notes

- The Isar database is stored in the app's documents directory
- Database content is persistent between app sessions
- Use kDebugMode checks when adding debugging code to avoid shipping debug features
- Remember to close the database connection when done: await isar.close()
