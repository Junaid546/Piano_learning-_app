import 'package:flutter/material.dart';

/// Piano settings model for the free piano feature.
/// Contains all user preferences for the piano experience.
@immutable
class PianoSettings {
  /// Number of octaves to display (1-4)
  final int octaveRange;

  /// Starting octave number (0-7)
  final int startingOctave;

  /// Whether to show note labels on keys
  final bool showNoteLabels;

  /// Whether to show octave numbers (e.g., C4 vs just C)
  final bool showOctaveNumbers;

  /// Whether sustain pedal is enabled
  final bool sustainEnabled;

  /// Whether sound is enabled (mute toggle)
  final bool soundEnabled;

  /// Volume level (0.0 to 1.0)
  final double volume;

  /// Color for key highlight when pressed
  final Color keyHighlightColor;

  /// Whether to animate key press visual feedback
  final bool keyPressAnimation;

  /// Whether to use touch pressure for velocity sensitivity
  final bool velocitySensitivity;

  /// Selected instrument sound (piano, organ, synth)
  final String selectedInstrument;

  const PianoSettings({
    this.octaveRange = 2,
    this.startingOctave = 3,
    this.showNoteLabels = true,
    this.showOctaveNumbers = false,
    this.sustainEnabled = false,
    this.soundEnabled = true,
    this.volume = 0.8,
    this.keyHighlightColor = const Color(0xFF7C4DFF),
    this.keyPressAnimation = true,
    this.velocitySensitivity = false,
    this.selectedInstrument = 'piano',
  });

  /// Create a copy with modified values
  PianoSettings copyWith({
    int? octaveRange,
    int? startingOctave,
    bool? showNoteLabels,
    bool? showOctaveNumbers,
    bool? sustainEnabled,
    bool? soundEnabled,
    double? volume,
    Color? keyHighlightColor,
    bool? keyPressAnimation,
    bool? velocitySensitivity,
    String? selectedInstrument,
  }) {
    return PianoSettings(
      octaveRange: octaveRange ?? this.octaveRange,
      startingOctave: startingOctave ?? this.startingOctave,
      showNoteLabels: showNoteLabels ?? this.showNoteLabels,
      showOctaveNumbers: showOctaveNumbers ?? this.showOctaveNumbers,
      sustainEnabled: sustainEnabled ?? this.sustainEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      volume: volume ?? this.volume,
      keyHighlightColor: keyHighlightColor ?? this.keyHighlightColor,
      keyPressAnimation: keyPressAnimation ?? this.keyPressAnimation,
      velocitySensitivity: velocitySensitivity ?? this.velocitySensitivity,
      selectedInstrument: selectedInstrument ?? this.selectedInstrument,
    );
  }

  /// Calculate the ending octave based on range
  int get endOctave => startingOctave + octaveRange - 1;

  /// Get total number of octaves
  int get totalOctaves => octaveRange;

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'octaveRange': octaveRange,
      'startingOctave': startingOctave,
      'showNoteLabels': showNoteLabels,
      'showOctaveNumbers': showOctaveNumbers,
      'sustainEnabled': sustainEnabled,
      'soundEnabled': soundEnabled,
      'volume': volume,
      'keyHighlightColor': keyHighlightColor.value,
      'keyPressAnimation': keyPressAnimation,
      'velocitySensitivity': velocitySensitivity,
      'selectedInstrument': selectedInstrument,
    };
  }

  /// Create from JSON
  factory PianoSettings.fromJson(Map<String, dynamic> json) {
    return PianoSettings(
      octaveRange: json['octaveRange'] ?? 2,
      startingOctave: json['startingOctave'] ?? 3,
      showNoteLabels: json['showNoteLabels'] ?? true,
      showOctaveNumbers: json['showOctaveNumbers'] ?? false,
      sustainEnabled: json['sustainEnabled'] ?? false,
      soundEnabled: json['soundEnabled'] ?? true,
      volume: (json['volume'] ?? 0.8).toDouble(),
      keyHighlightColor: Color(json['keyHighlightColor'] ?? 0xFF7C4DFF),
      keyPressAnimation: json['keyPressAnimation'] ?? true,
      velocitySensitivity: json['velocitySensitivity'] ?? false,
      selectedInstrument: json['selectedInstrument'] ?? 'piano',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PianoSettings &&
        other.octaveRange == octaveRange &&
        other.startingOctave == startingOctave &&
        other.showNoteLabels == showNoteLabels &&
        other.showOctaveNumbers == showOctaveNumbers &&
        other.sustainEnabled == sustainEnabled &&
        other.soundEnabled == soundEnabled &&
        other.volume == volume &&
        other.keyHighlightColor == keyHighlightColor &&
        other.keyPressAnimation == keyPressAnimation &&
        other.velocitySensitivity == velocitySensitivity &&
        other.selectedInstrument == selectedInstrument;
  }

  @override
  int get hashCode {
    return Object.hash(
      octaveRange,
      startingOctave,
      showNoteLabels,
      showOctaveNumbers,
      sustainEnabled,
      soundEnabled,
      volume,
      keyHighlightColor,
      keyPressAnimation,
      velocitySensitivity,
      selectedInstrument,
    );
  }
}
