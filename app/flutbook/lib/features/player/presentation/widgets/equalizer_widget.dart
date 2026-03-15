// lib/features/player/presentation/widgets/equalizer_widget.dart
import 'package:flutter/material.dart';

/// Widget for displaying and controlling equalizer bands.
class EqualizerWidget extends StatelessWidget {
  const EqualizerWidget({
    required this.eqBands,
    required this.onBandChanged,
    super.key,
  });

  final Map<String, double> eqBands;
  final void Function(String band, double value) onBandChanged;

  @override
  Widget build(BuildContext context) {
    final bands = eqBands.entries.toList()
      ..sort((a, b) => _getBandOrder(a.key).compareTo(_getBandOrder(b.key)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Equalizer',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...bands.map((entry) => _buildBandSlider(context, entry.key, entry.value)),
      ],
    );
  }

  Widget _buildBandSlider(BuildContext context, String band, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              band,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: -12,
              max: 12,
              divisions: 24,
              label: '${value.toStringAsFixed(1)} dB',
              onChanged: (newValue) => onBandChanged(band, newValue),
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              '${value.toStringAsFixed(1)} dB',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  int _getBandOrder(String band) {
    switch (band) {
      case '60Hz':
        return 0;
      case '230Hz':
        return 1;
      case '910Hz':
        return 2;
      case '3.6kHz':
        return 3;
      case '14kHz':
        return 4;
      default:
        return 5;
    }
  }
}
