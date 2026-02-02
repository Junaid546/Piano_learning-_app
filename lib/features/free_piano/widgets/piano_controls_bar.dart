import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/piano_controller_provider.dart';

/// Top control bar for the landscape piano screen.
/// Contains back button, octave selector, volume, settings, record, and sustain controls.
class PianoControlsBar extends ConsumerWidget {
  const PianoControlsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pianoState = ref.watch(pianoControllerProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          // Back button
          _buildBackButton(context),

          const SizedBox(width: 12),

          // Octave range display
          _buildOctaveRange(context, pianoState),

          const Spacer(),

          // Center - App title or "Free Play"
          Text(
            'Free Play',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          const Spacer(),

          // Right side controls
          Row(
            children: [
              // Volume control
              _buildVolumeControl(context, ref, pianoState),

              const SizedBox(width: 8),

              // Settings
              _buildSettingsButton(context),

              const SizedBox(width: 8),

              // Record button
              _buildRecordButton(context),

              const SizedBox(width: 8),

              // Sustain toggle
              _buildSustainButton(context, ref, pianoState),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => Navigator.of(context).pop(),
      tooltip: 'Exit Free Play',
    );
  }

  Widget _buildOctaveRange(BuildContext context, PianoControllerState state) {
    return GestureDetector(
      onTap: () {
        // TODO: Show octave selector bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Octave selector coming soon')),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          state.octaveRange.displayString,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildVolumeControl(
    BuildContext context,
    WidgetRef ref,
    PianoControllerState state,
  ) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            state.isMuted
                ? Icons.volume_off
                : state.volume < 0.5
                    ? Icons.volume_down
                    : Icons.volume_up,
            color: Colors.white,
          ),
          onPressed: () => ref.read(pianoControllerProvider.notifier).toggleMute(),
        ),
        SizedBox(
          width: 80,
          child: Slider(
            value: state.volume,
            onChanged: (value) =>
                ref.read(pianoControllerProvider.notifier).setVolume(value),
            activeColor: Colors.purple,
            inactiveColor: Colors.white.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings, color: Colors.white),
      onPressed: () {
        // TODO: Show settings bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings coming soon')),
        );
      },
      tooltip: 'Settings',
    );
  }

  Widget _buildRecordButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.fiber_manual_record, color: Colors.red),
      onPressed: () {
        // TODO: Toggle recording
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recording coming soon')),
        );
      },
      tooltip: 'Record',
    );
  }

  Widget _buildSustainButton(
    BuildContext context,
    WidgetRef ref,
    PianoControllerState state,
  ) {
    return IconButton(
      icon: Icon(
        Icons.pedal_bike,
        color: state.sustainEnabled ? Colors.purple : Colors.white,
      ),
      onPressed: () =>
          ref.read(pianoControllerProvider.notifier).toggleSustain(),
      tooltip: 'Sustain Pedal',
    );
  }
}
