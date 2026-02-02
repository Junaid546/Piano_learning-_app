import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'piano_key.dart';

/// Octave range model representing a range of piano octaves.
/// Contains all keys (white and black) within the specified range.
@immutable
class OctaveRange {
  /// Starting octave number
  final int startOctave;

  /// Ending octave number
  final int endOctave;

  /// Total number of keys in this range
  final int totalKeys;

  /// All white keys in this range
  final List<PianoKey> whiteKeys;

  /// All black keys in this range
  final List<PianoKey> blackKeys;

  const OctaveRange({
    required this.startOctave,
    required this.endOctave,
    required this.totalKeys,
    required this.whiteKeys,
    required this.blackKeys,
  });

  /// Create an octave range from start octave and number of octaves
  factory OctaveRange.fromStartAndRange(int startOctave, int numOctaves) {
    final endOctave = startOctave + numOctaves - 1;
    final whiteKeys = <PianoKey>[];
    final blackKeys = <PianoKey>[];

    for (int octave = startOctave; octave <= endOctave; octave++) {
      // Add white keys for this octave
      whiteKeys.add(PianoKey(note: 'C', octave: octave));
      whiteKeys.add(PianoKey(note: 'D', octave: octave));
      whiteKeys.add(PianoKey(note: 'E', octave: octave));
      whiteKeys.add(PianoKey(note: 'F', octave: octave));
      whiteKeys.add(PianoKey(note: 'G', octave: octave));
      whiteKeys.add(PianoKey(note: 'A', octave: octave));
      whiteKeys.add(PianoKey(note: 'B', octave: octave));

      // Add black keys for this octave
      blackKeys.add(PianoKey(note: 'Db', octave: octave));
      blackKeys.add(PianoKey(note: 'Eb', octave: octave));
      blackKeys.add(PianoKey(note: 'Gb', octave: octave));
      blackKeys.add(PianoKey(note: 'Ab', octave: octave));
      blackKeys.add(PianoKey(note: 'Bb', octave: octave));
    }

    final totalKeys = whiteKeys.length + blackKeys.length;

    return OctaveRange(
      startOctave: startOctave,
      endOctave: endOctave,
      totalKeys: totalKeys,
      whiteKeys: whiteKeys,
      blackKeys: blackKeys,
    );
  }

  /// Get all keys (white + black) combined
  List<PianoKey> getAllKeys() {
    return [...whiteKeys, ...blackKeys];
  }

  /// Get a key by note name and octave
  /// Returns null if not found
  PianoKey? getKeyByNote(String noteName, int octave) {
    // Normalize note name (handle sharp/flat variations)
    final normalizedNote = _normalizeNoteName(noteName);

    for (final key in getAllKeys()) {
      if (key.note == normalizedNote && key.octave == octave) {
        return key;
      }
    }
    return null;
  }

  /// Get the range as a display string (e.g., "C3-B4")
  String get displayString {
    final firstKey = whiteKeys.first;
    final lastKey = whiteKeys.last;
    return '${firstKey.fullName}-${lastKey.fullName}';
  }

  /// Get number of octaves in this range
  int get numOctaves => endOctave - startOctave + 1;

  /// Normalize note name to standard format
  String _normalizeNoteName(String noteName) {
    final sharpToFlat = {
      'C#': 'Db',
      'D#': 'Eb',
      'F#': 'Gb',
      'G#': 'Ab',
      'A#': 'Bb',
    };
    return sharpToFlat[noteName] ?? noteName;
  }

  /// Calculate note frequency using equal temperament
  /// A4 = 440Hz is the reference
  static double getNoteFrequency(String note, int octave) {
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OctaveRange &&
        other.startOctave == startOctave &&
        other.endOctave == endOctave &&
        other.totalKeys == totalKeys;
  }

  @override
  int get hashCode {
    return Object.hash(startOctave, endOctave, totalKeys);
  }
}
