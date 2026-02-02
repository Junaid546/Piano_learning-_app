import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/piano_key.dart';
import '../models/octave_range.dart';
import '../models/piano_settings.dart';
import '../../../features/piano/providers/audio_service_provider.dart';
import '../../../features/piano/services/audio_player_service.dart';

/// State for the piano controller
class PianoControllerState {
  /// Currently active (pressed) keys
  final Set<String> activeKeys;

  /// Current octave range
  final OctaveRange octaveRange;

  /// Whether sustain pedal is enabled
  final bool sustainEnabled;

  /// Current volume level
  final double volume;

  /// Whether sound is muted
  final bool isMuted;

  /// Currently pressed notes for sustain handling
  final Map<String, DateTime> pressedNotes;

  const PianoControllerState({
    this.activeKeys = const {},
    required this.octaveRange,
    this.sustainEnabled = false,
    this.volume = 0.8,
    this.isMuted = false,
    this.pressedNotes = const {},
  });

  PianoControllerState copyWith({
    Set<String>? activeKeys,
    OctaveRange? octaveRange,
    bool? sustainEnabled,
    double? volume,
    bool? isMuted,
    Map<String, DateTime>? pressedNotes,
  }) {
    return PianoControllerState(
      activeKeys: activeKeys ?? this.activeKeys,
      octaveRange: octaveRange ?? this.octaveRange,
      sustainEnabled: sustainEnabled ?? this.sustainEnabled,
      volume: volume ?? this.volume,
      isMuted: isMuted ?? this.isMuted,
      pressedNotes: pressedNotes ?? this.pressedNotes,
    );
  }

  /// Check if a specific key is active
  bool isKeyActive(String note, int octave) {
    return activeKeys.contains('$note$octave');
  }
}

/// Controller for piano state management
class PianoController extends StateNotifier<PianoControllerState> {
  final AudioPlayerService _audioService;
  final Set<String> _sustainedNotes = {};

  PianoController(this._audioService)
      : super(PianoControllerState(
          octaveRange: OctaveRange.fromStartAndRange(3, 2),
        )) {
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    if (!_audioService.isInitialized) {
      await _audioService.initialize();
    }
  }

  /// Press a key
  void pressKey(String note, int octave, [double velocity = 0.8]) {
    final keyId = '$note$octave';
    final pianoKey = PianoKey(note: note, octave: octave);

    // Play the note
    if (!state.isMuted) {
      _audioService.playNoteByName(pianoKey.fullName);
    }

    // Track pressed note with timestamp for sustain
    final pressedNotes = Map<String, DateTime>.from(state.pressedNotes);
    pressedNotes[keyId] = DateTime.now();

    // Add to active keys
    final activeKeys = Set<String>.from(state.activeKeys);
    activeKeys.add(keyId);

    // If sustain is enabled, track this note
    if (state.sustainEnabled) {
      _sustainedNotes.add(keyId);
    }

    state = state.copyWith(
      activeKeys: activeKeys,
      pressedNotes: pressedNotes,
    );
  }

  /// Release a key
  void releaseKey(String note, int octave) {
    final keyId = '$note$octave';

    // Remove from active keys
    final activeKeys = Set<String>.from(state.activeKeys);
    activeKeys.remove(keyId);

    // Remove from pressed notes
    final pressedNotes = Map<String, DateTime>.from(state.pressedNotes);
    pressedNotes.remove(keyId);

    // Don't stop audio - let it play naturally
    // The audio service handles its own playback

    state = state.copyWith(
      activeKeys: activeKeys,
      pressedNotes: pressedNotes,
    );
  }

  /// Replay a single note (used after releasing another key with sustain on)
  void _replayNote(String keyId) {
    if (state.isMuted) return;

    // Parse the key ID to get note and octave
    final match = RegExp(r'([A-Gb]+)(\d+)').firstMatch(keyId);
    if (match != null) {
      final note = match.group(1)!;
      final octave = int.parse(match.group(2)!);
      _audioService.playNoteByName('$note$octave');
    }
  }

  /// Set octave range
  void setOctaveRange(int startOctave, int numOctaves) {
    final newRange = OctaveRange.fromStartAndRange(startOctave, numOctaves);
    state = state.copyWith(octaveRange: newRange);
  }

  /// Set number of octaves
  void setNumOctaves(int numOctaves) {
    setOctaveRange(state.octaveRange.startOctave, numOctaves);
  }

  /// Set starting octave
  void setStartingOctave(int octave) {
    setOctaveRange(octave, state.octaveRange.numOctaves);
  }

  /// Toggle sustain pedal
  void toggleSustain() {
    final newSustainEnabled = !state.sustainEnabled;
    state = state.copyWith(sustainEnabled: newSustainEnabled);

    if (!newSustainEnabled) {
      // Turn off sustain - clear sustained notes tracking
      _sustainedNotes.clear();
      // Don't stop audio - let it fade naturally
    }
  }

  /// Set sustain enabled
  void setSustain(bool enabled) {
    if (enabled != state.sustainEnabled) {
      toggleSustain();
    }
  }

  /// Set volume
  void setVolume(double volume) {
    final clampedVolume = volume.clamp(0.0, 1.0);
    _audioService.setVolume(clampedVolume);
    state = state.copyWith(volume: clampedVolume);
  }

  /// Toggle mute
  void toggleMute() {
    if (state.isMuted) {
      _audioService.unmute();
      state = state.copyWith(isMuted: false);
    } else {
      _audioService.mute();
      state = state.copyWith(isMuted: true);
    }
  }

  /// Set mute
  void setMute(bool muted) {
    if (muted != state.isMuted) {
      toggleMute();
    }
  }

  /// Stop all sounds
  void stopAll() {
    _audioService.stopAll();
    _sustainedNotes.clear();
    state = state.copyWith(
      activeKeys: {},
      pressedNotes: {},
    );
  }

  /// Get the display name for a key
  String getKeyDisplayName(PianoKey key, bool showOctave) {
    if (showOctave) {
      return key.fullName;
    }
    return key.note;
  }
}

/// Provider for the piano controller
final pianoControllerProvider = StateNotifierProvider<PianoController, PianoControllerState>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return PianoController(audioService);
});

/// Provider for active keys count (for visualizer)
final activeKeysCountProvider = Provider<int>((ref) {
  final state = ref.watch(pianoControllerProvider);
  return state.activeKeys.length;
});

/// Provider for sustain state
final sustainEnabledProvider = Provider<bool>((ref) {
  final state = ref.watch(pianoControllerProvider);
  return state.sustainEnabled;
});

/// Provider for volume level
final volumeProvider = Provider<double>((ref) {
  final state = ref.watch(pianoControllerProvider);
  return state.volume;
});

/// Provider for muted state
final isMutedProvider = Provider<bool>((ref) {
  final state = ref.watch(pianoControllerProvider);
  return state.isMuted;
});
