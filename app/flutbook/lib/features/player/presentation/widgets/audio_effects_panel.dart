// lib/features/player/presentation/widgets/audio_effects_panel.dart
import 'package:flutbook/features/player/domain/entities/audio_effect.dart';
import 'package:flutbook/features/player/presentation/providers/audio_effects_provider.dart';
import 'package:flutbook/features/player/presentation/widgets/equalizer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Panel for managing audio effects including EQ, bass boost, and treble boost.
class AudioEffectsPanel extends ConsumerStatefulWidget {
  const AudioEffectsPanel({super.key});

  @override
  ConsumerState<AudioEffectsPanel> createState() => _AudioEffectsPanelState();
}

class _AudioEffectsPanelState extends ConsumerState<AudioEffectsPanel> {
  @override
  void initState() {
    super.initState();
    // Load audio effects when panel is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioEffectsProvider.notifier).loadAudioEffects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final audioEffectsState = ref.watch(audioEffectsProvider);
    final audioEffectsNotifier = ref.read(audioEffectsProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Audio Effects',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Loading indicator
          if (audioEffectsState.isLoading)
            const Center(child: CircularProgressIndicator())
          else ...[
            // Preset selector
            _buildPresetSelector(context, audioEffectsState, audioEffectsNotifier),
            const SizedBox(height: 24),

            // Bass boost slider
            _buildBassBoostSlider(context, audioEffectsState, audioEffectsNotifier),
            const SizedBox(height: 16),

            // Treble boost slider
            _buildTrebleBoostSlider(context, audioEffectsState, audioEffectsNotifier),
            const SizedBox(height: 24),

            // Equalizer
            if (audioEffectsState.currentEffect != null)
              EqualizerWidget(
                eqBands: audioEffectsState.currentEffect!.eqBands,
                onBandChanged: (band, value) {
                  final updatedBands = Map<String, double>.from(
                    audioEffectsState.currentEffect!.eqBands,
                  );
                  updatedBands[band] = value;
                  audioEffectsNotifier.updateEqBands(updatedBands);
                },
              ),
            const SizedBox(height: 16),

            // Reset button
            Center(
              child: OutlinedButton.icon(
                onPressed: audioEffectsState.currentEffect != null
                    ? audioEffectsNotifier.resetCurrentEffect
                    : null,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset to Default'),
              ),
            ),
          ],

          // Error message
          if (audioEffectsState.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                audioEffectsState.errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPresetSelector(
    BuildContext context,
    AudioEffectsState state,
    AudioEffectsNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Presets',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildPresetChip(context, 'Default', null, state, notifier),
            _buildPresetChip(context, 'Music', 'music', state, notifier),
            _buildPresetChip(context, 'Podcast', 'podcast', state, notifier),
            _buildPresetChip(context, 'Bass Boost', 'bass_boost', state, notifier),
            _buildPresetChip(context, 'Treble Boost', 'treble_boost', state, notifier),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetChip(
    BuildContext context,
    String label,
    String? presetName,
    AudioEffectsState state,
    AudioEffectsNotifier notifier,
  ) {
    final isSelected =
        state.currentEffect?.presetName == presetName ||
        (presetName == null && state.currentEffect == null);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          // Find the preset effect or create default
          if (presetName == null) {
            notifier.disableAllEffects();
          } else {
            final presetEffect = state.effects.firstWhere(
              (effect) => effect.presetName == presetName,
              orElse: AudioEffect.defaultEffect,
            );
            notifier.setCurrentAudioEffect(presetEffect.id);
          }
        }
      },
    );
  }

  Widget _buildBassBoostSlider(
    BuildContext context,
    AudioEffectsState state,
    AudioEffectsNotifier notifier,
  ) {
    final bassBoost = state.currentEffect?.bassBoost ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Bass Boost',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '${(bassBoost * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        Slider(
          value: bassBoost,
          divisions: 10,
          onChanged: state.currentEffect != null
              ? (value) => notifier.updateBassBoost(value)
              : null,
        ),
      ],
    );
  }

  Widget _buildTrebleBoostSlider(
    BuildContext context,
    AudioEffectsState state,
    AudioEffectsNotifier notifier,
  ) {
    final trebleBoost = state.currentEffect?.trebleBoost ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Treble Boost',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '${(trebleBoost * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        Slider(
          value: trebleBoost,
          divisions: 10,
          onChanged: state.currentEffect != null
              ? (value) => notifier.updateTrebleBoost(value)
              : null,
        ),
      ],
    );
  }
}
