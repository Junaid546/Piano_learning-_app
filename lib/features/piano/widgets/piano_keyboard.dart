import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/piano_key.dart';
import '../services/audio_player_service.dart';
import 'white_key.dart';
import 'black_key.dart';

class PianoKeyboard extends StatefulWidget {
  final int numberOfOctaves;
  final bool showLabels;
  final List<Note>? highlightedNotes;
  final Function(Note)? onNotePlayed;
  final bool enableSound;
  final double keyWidth;
  final double keyHeight;

  const PianoKeyboard({
    super.key,
    this.numberOfOctaves = 1,
    this.showLabels = true,
    this.highlightedNotes,
    this.onNotePlayed,
    this.enableSound = true,
    this.keyWidth = 50,
    this.keyHeight = 180,
  });

  @override
  State<PianoKeyboard> createState() => _PianoKeyboardState();
}

class _PianoKeyboardState extends State<PianoKeyboard> {
  final AudioPlayerService _audioService = AudioPlayerService();
  final Map<Note, PianoKey> _keys = {};
  final Set<Note> _pressedNotes = {};

  @override
  void initState() {
    super.initState();
    _initializeKeys();
    if (widget.enableSound) {
      _audioService.initialize();
    }
  }

  void _initializeKeys() {
    _keys.clear();
    for (int octave = 4; octave < 4 + widget.numberOfOctaves; octave++) {
      final notes = Note.getOctave(octave);
      for (final note in notes) {
        _keys[note] = PianoKey(
          note: note,
          isHighlighted: widget.highlightedNotes?.contains(note) ?? false,
          highlightColor: widget.highlightedNotes?.contains(note) ?? false
              ? Colors.blue
              : null,
        );
      }
    }
  }

  @override
  void didUpdateWidget(PianoKeyboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.highlightedNotes != widget.highlightedNotes) {
      _updateHighlights();
    }
  }

  void _updateHighlights() {
    setState(() {
      for (final entry in _keys.entries) {
        final isHighlighted =
            widget.highlightedNotes?.contains(entry.key) ?? false;
        _keys[entry.key] = entry.value.copyWith(
          isHighlighted: isHighlighted,
          highlightColor: isHighlighted ? Colors.blue : null,
          clearHighlightColor: !isHighlighted,
        );
      }
    });
  }

  void _handleKeyPress(Note note) {
    setState(() {
      _pressedNotes.add(note);
      _keys[note] = _keys[note]!.copyWith(isPressed: true);
    });

    if (widget.enableSound) {
      _audioService.playNote(note);
    }

    widget.onNotePlayed?.call(note);
  }

  void _handleKeyRelease(Note note) {
    setState(() {
      _pressedNotes.remove(note);
      _keys[note] = _keys[note]!.copyWith(isPressed: false);
    });
  }

  List<Note> _getWhiteNotes() {
    return _keys.keys.where((note) => !note.isSharp).toList();
  }

  List<Note> _getBlackNotes() {
    return _keys.keys.where((note) => note.isSharp).toList();
  }

  // Calculate black key position relative to white keys
  double _getBlackKeyOffset(Note blackNote) {
    final whiteNotes = _getWhiteNotes();
    final noteName = blackNote.noteName;
    final octave = blackNote.octave;

    // Find the white key before this black key
    int whiteKeyIndex = 0;
    if (noteName == 'C') {
      // C# is after C
      whiteKeyIndex = whiteNotes.indexWhere(
        (n) => n.noteName == 'C' && n.octave == octave,
      );
    } else if (noteName == 'D') {
      // D# is after D
      whiteKeyIndex = whiteNotes.indexWhere(
        (n) => n.noteName == 'D' && n.octave == octave,
      );
    } else if (noteName == 'F') {
      // F# is after F
      whiteKeyIndex = whiteNotes.indexWhere(
        (n) => n.noteName == 'F' && n.octave == octave,
      );
    } else if (noteName == 'G') {
      // G# is after G
      whiteKeyIndex = whiteNotes.indexWhere(
        (n) => n.noteName == 'G' && n.octave == octave,
      );
    } else if (noteName == 'A') {
      // A# is after A
      whiteKeyIndex = whiteNotes.indexWhere(
        (n) => n.noteName == 'A' && n.octave == octave,
      );
    }

    // Position black key between white keys
    final whiteKeyWidth = widget.keyWidth + 2; // +2 for margins
    final blackKeyWidth = widget.keyWidth * 0.6;
    return (whiteKeyIndex * whiteKeyWidth) +
        (whiteKeyWidth - blackKeyWidth / 2);
  }

  @override
  Widget build(BuildContext context) {
    final whiteNotes = _getWhiteNotes();
    final blackNotes = _getBlackNotes();
    final totalWidth = whiteNotes.length * (widget.keyWidth + 2);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey.shade900, Colors.grey.shade800],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: totalWidth,
          height: widget.keyHeight + 40,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Stack(
              children: [
                // White keys layer
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: whiteNotes.map((note) {
                    return WhiteKey(
                      pianoKey: _keys[note]!,
                      onPressed: () => _handleKeyPress(note),
                      onReleased: () => _handleKeyRelease(note),
                      showLabel: widget.showLabels,
                      width: widget.keyWidth,
                      height: widget.keyHeight,
                    );
                  }).toList(),
                ),
                // Black keys layer (positioned absolutely)
                ...blackNotes.map((note) {
                  return Positioned(
                    left: _getBlackKeyOffset(note),
                    top: 0,
                    child: BlackKey(
                      pianoKey: _keys[note]!,
                      onPressed: () => _handleKeyPress(note),
                      onReleased: () => _handleKeyRelease(note),
                      showLabel: widget.showLabels,
                      whiteKeyWidth: widget.keyWidth,
                      whiteKeyHeight: widget.keyHeight,
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (widget.enableSound) {
      _audioService.dispose();
    }
    super.dispose();
  }
}
