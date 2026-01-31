import 'package:flutter/material.dart';
import 'note.dart';

class PianoKey {
  final Note note;
  final bool isPressed;
  final bool isHighlighted;
  final Color? highlightColor;

  const PianoKey({
    required this.note,
    this.isPressed = false,
    this.isHighlighted = false,
    this.highlightColor,
  });

  PianoKey copyWith({
    Note? note,
    bool? isPressed,
    bool? isHighlighted,
    Color? highlightColor,
    bool clearHighlightColor = false,
  }) {
    return PianoKey(
      note: note ?? this.note,
      isPressed: isPressed ?? this.isPressed,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      highlightColor: clearHighlightColor
          ? null
          : (highlightColor ?? this.highlightColor),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PianoKey &&
          runtimeType == other.runtimeType &&
          note == other.note &&
          isPressed == other.isPressed &&
          isHighlighted == other.isHighlighted &&
          highlightColor == other.highlightColor;

  @override
  int get hashCode =>
      note.hashCode ^
      isPressed.hashCode ^
      isHighlighted.hashCode ^
      highlightColor.hashCode;
}
