import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Represents a single piano key (white or black).
/// Contains all information needed to identify and play the note.
@immutable
class PianoKey {
  /// The note name (C, Db, D, Eb, E, F, Gb, G, Ab, A, Bb, B)
  final String note;

  /// The octave number (0-8)
  final int octave;

  const PianoKey({
    required this.note,
    required this.octave,
  });

  /// Full note name including octave (e.g., "C4", "Db4")
  String get fullName => '$note$octave';

  /// Whether this is a white key
  bool get isWhiteKey {
    return ['C', 'D', 'E', 'F', 'G', 'A', 'B'].contains(note);
  }

  /// Whether this is a black key
  bool get isBlackKey => !isWhiteKey;

  /// Get the MIDI note number for this key
  /// Middle C (C4) = 60
  int get midiNumber {
    final noteToSemitone = {
      'C': 0,
      'Db': 1,
      'D': 2,
      'Eb': 3,
      'E': 4,
      'F': 5,
      'Gb': 6,
      'G': 7,
      'Ab': 8,
      'A': 9,
      'Bb': 10,
      'B': 11,
    };
    return (octave + 1) * 12 + (noteToSemitone[note] ?? 0);
  }

  /// Get the frequency of this note in Hz
  /// A4 = 440Hz is the reference
  double get frequency {
    // Map note names to semitone offsets from A
    final noteOffsets = {
      'C': -9,
      'Db': -8,
      'D': -7,
      'Eb': -6,
      'E': -5,
      'F': -4,
      'Gb': -3,
      'G': -2,
      'Ab': -1,
      'A': 0,
      'Bb': 1,
      'B': 2,
    };

    // Calculate semitones from A4
    final noteOffset = noteOffsets[note] ?? 0;
    final octaveOffset = (octave - 4) * 12;
    final totalSemitones = noteOffset + octaveOffset;

    // Calculate frequency using A4 = 440Hz
    return 440.0 * math.pow(2, totalSemitones / 12);
  }

  /// Get the audio asset path for this key's note
  String get audioAssetPath {
    // Use flat naming for sharp notes to match asset files
    final flatNote = _sharpToFlat(note);
    return 'audio/piano/$flatNote$octave.mp3';
  }

  /// Convert sharp note names to flat for file naming
  String _sharpToFlat(String note) {
    final sharpToFlat = {
      'C#': 'Db',
      'D#': 'Eb',
      'F#': 'Gb',
      'G#': 'Ab',
      'A#': 'Bb',
    };
    return sharpToFlat[note] ?? note;
  }

  /// Get the position index within an octave (0-11)
  int get positionInOctave {
    final positions = {
      'C': 0,
      'Db': 1,
      'D': 2,
      'Eb': 3,
      'E': 4,
      'F': 5,
      'Gb': 6,
      'G': 7,
      'Ab': 8,
      'A': 9,
      'Bb': 10,
      'B': 11,
    };
    return positions[note] ?? 0;
  }

  /// Get the next key going upward
  PianoKey get nextKey {
    if (note == 'B') {
      return PianoKey(note: 'C', octave: octave + 1);
    } else if (note == 'Bb') {
      return PianoKey(note: 'B', octave: octave);
    } else if (note == 'Ab') {
      return PianoKey(note: 'Bb', octave: octave);
    } else if (note == 'Gb') {
      return PianoKey(note: 'Ab', octave: octave);
    } else if (note == 'Eb') {
      return PianoKey(note: 'Gb', octave: octave);
    } else if (note == 'Db') {
      return PianoKey(note: 'Eb', octave: octave);
    } else {
      // White keys go up by one letter
      final whiteKeys = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
      final currentIndex = whiteKeys.indexOf(note);
      if (currentIndex < whiteKeys.length - 1) {
        return PianoKey(note: whiteKeys[currentIndex + 1], octave: octave);
      }
      return PianoKey(note: 'C', octave: octave + 1);
    }
  }

  /// Get the previous key going downward
  PianoKey get previousKey {
    if (note == 'C') {
      return PianoKey(note: 'B', octave: octave - 1);
    } else if (note == 'B') {
      return PianoKey(note: 'Bb', octave: octave);
    } else if (note == 'Bb') {
      return PianoKey(note: 'A', octave: octave);
    } else if (note == 'Ab') {
      return PianoKey(note: 'G', octave: octave);
    } else if (note == 'Gb') {
      return PianoKey(note: 'F', octave: octave);
    } else if (note == 'Eb') {
      return PianoKey(note: 'D', octave: octave);
    } else if (note == 'Db') {
      return PianoKey(note: 'C', octave: octave);
    } else {
      // White keys go down by one letter
      final whiteKeys = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
      final currentIndex = whiteKeys.indexOf(note);
      if (currentIndex > 0) {
        return PianoKey(note: whiteKeys[currentIndex - 1], octave: octave);
      }
      return PianoKey(note: 'B', octave: octave - 1);
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PianoKey &&
        other.note == note &&
        other.octave == octave;
  }

  @override
  int get hashCode => Object.hash(note, octave);

  @override
  String toString() => 'PianoKey($fullName)';
}
