# MVP Gemini: Audiobook Player

This document outlines the user flow, potential problems, and a step-by-step implementation plan for the MVP of the Flutbook audiobook player.

## User Flow

The intended user flow is as follows:

1.  **Book Selection**: The user selects an audiobook from their library.
2.  **Playback Screen**: The app navigates to the `PlaybackScreen`, passing the selected `AudiobookModel`.
3.  **UI Display**: The `PlaybackScreen` displays the audiobook's cover art, title, and author.
4.  **Playback Control**: The user interacts with the `PlaybackControls` to:
    *   Play/pause the audiobook.
    *   Skip forward or backward.
    *   Adjust the playback speed.
    *   Set a sleep timer.
5.  **Progress Tracking**: The `ProgressBar` displays the current playback position and total duration, and allows the user to seek to different parts of the audiobook.

## Potential Problems

The primary challenge is that the current implementation is a UI shell with no backend functionality. The UI is not connected to an audio playback engine.

1.  **No Playback Engine**: There is no audio player integrated (e.g., `just_audio`, `audioplayers`).
2.  **State Management**: The UI uses local `setState` for placeholder logic. This needs to be replaced with a robust state management solution (like Riverpod, which seems to be used in the project) to handle the audio player's state (playing, paused, buffering, etc.).
3.  **Data Source**: The process of how an `AudiobookModel` is created and passed to the player is not fully clear and needs to be investigated further. This likely originates from the `library` and `directory_selection` features.

## Step-by-Step Implementation Plan

To implement the MVP, we will focus on core functionality first and gradually enable other features.

### Step 1: Core Playback Functionality

1.  **Integrate an Audio Player**: Choose and integrate an audio player package like `just_audio`.
2.  **Implement Audio Service**: Create a service that handles the audio playback logic (play, pause, seek, etc.).
3.  **Connect UI to State**:
    *   Connect the `onPlayPause` callback in `playback_screen.dart` to the audio service.
    *   Update the `ProgressBar` with the player's position stream.
    *   The `features/playback/presentation/views/playback_screen.dart` will be modified to use a state management solution (Riverpod) to interact with the audio service.

### Step 2: Deferrable Features (Comment Out)

For the initial MVP, we can comment out the following features to reduce complexity. These can be enabled one by one in future iterations.

1.  **Playback Speed Control**: In `app/flutbook/lib/features/playback/presentation/widgets/playback_controls.dart`, comment out the `DropdownButton` for playback speed.

    ```dart
    // In lib/features/playback/presentation/widgets/playback_controls.dart

    // Row(
    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //   children: [
    //     // ... other controls
    //     DropdownButton<double>(
    //       value: 1.0,
    //       onChanged: (value) {
    //         // setState(() {
    //         //   _playbackSpeed = value!;
    //         // });
    //       },
    //       items: const [
    //         DropdownMenuItem(value: 0.5, child: Text('0.5x')),
    //         DropdownMenuItem(value: 1.0, child: Text('1.0x')),
    //         DropdownMenuItem(value: 1.5, child: Text('1.5x')),
    //         DropdownMenuItem(value: 2.0, child: Text('2.0x')),
    //       ],
    //     ),
    //   ],
    // ),
    ```

2.  **Sleep Timer**: In `app/flutbook/lib/features/playback/presentation/widgets/playback_controls.dart`, comment out the "Sleep Timer" button.

    ```dart
    // In lib/features/playback/presentation/widgets/playback_controls.dart

    // OutlinedButton.icon(
    //   onPressed: () {
    //     // show sleep timer bottom sheet
    //   },
    //   icon: const Icon(Icons.timer_outlined),
    //   label: const Text('Sleep Timer'),
    // ),
    ```

3.  **Previous/Next Chapter**: The previous/next chapter buttons are already non-functional, so we can leave them as is for now, but they will not be wired up in the MVP.

By following this plan, we can build a functional MVP and then incrementally add more features.
