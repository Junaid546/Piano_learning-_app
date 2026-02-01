import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/piano_key.dart';
import '../services/audio_player_service.dart';
import 'white_key.dart';
import 'black_key.dart';

/// A responsive piano keyboard widget that handles overflow gracefully
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
    this.keyWidth = 45, // Smaller default for better fit
    this.keyHeight = 160, // Smaller default
  });

  @override
  State<PianoKeyboard> createState() => _PianoKeyboardState();
}

class _PianoKeyboardState extends State<PianoKeyboard> {
  final AudioPlayerService _audioService = AudioPlayerService();
  final Map<Note, PianoKey> _keys = {};
  final Set<Note> _pressedNotes = {};
  bool _audioInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeKeys();
    _initAudio();
  }

  Future<void> _initAudio() async {
    if (widget.enableSound && !_audioInitialized) {
      await _audioService.initialize();
      _audioInitialized = true;
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
    if (oldWidget.numberOfOctaves != widget.numberOfOctaves) {
      _initializeKeys();
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
    if (!mounted) return;

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
    if (!mounted) return;

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
  double _getBlackKeyOffset(Note blackNote, double actualKeyWidth) {
    final whiteNotes = _getWhiteNotes();
    final noteName = blackNote.noteName;
    final octave = blackNote.octave;

    // Find the white key before this black key
    int whiteKeyIndex = 0;
    if (noteName == 'C') {
      whiteKeyIndex = whiteNotes.indexWhere(
        (n) => n.noteName == 'C' && n.octave == octave,
      );
    } else if (noteName == 'D') {
      whiteKeyIndex = whiteNotes.indexWhere(
        (n) => n.noteName == 'D' && n.octave == octave,
      );
    } else if (noteName == 'F') {
      whiteKeyIndex = whiteNotes.indexWhere(
        (n) => n.noteName == 'F' && n.octave == octave,
      );
    } else if (noteName == 'G') {
      whiteKeyIndex = whiteNotes.indexWhere(
        (n) => n.noteName == 'G' && n.octave == octave,
      );
    } else if (noteName == 'A') {
      whiteKeyIndex = whiteNotes.indexWhere(
        (n) => n.noteName == 'A' && n.octave == octave,
      );
    }

    if (whiteKeyIndex < 0) whiteKeyIndex = 0;

    // Position black key between white keys
    final whiteKeyWidthWithMargin = actualKeyWidth + 2;
    final blackKeyWidth = actualKeyWidth * 0.6;
    return (whiteKeyIndex * whiteKeyWidthWithMargin) +
        (whiteKeyWidthWithMargin - blackKeyWidth / 2);
  }

  @override
  Widget build(BuildContext context) {
    final whiteNotes = _getWhiteNotes();
    final blackNotes = _getBlackNotes();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive key width based on available space
        final availableWidth = constraints.maxWidth - 40; // Account for padding
        final idealTotalWidth = whiteNotes.length * (widget.keyWidth + 2);

        // Use scrolling if content is wider than available space
        final needsScroll = idealTotalWidth > availableWidth;
        final actualKeyWidth = needsScroll
            ? widget.keyWidth
            : (availableWidth / whiteNotes.length) - 2;

        final totalWidth = whiteNotes.length * (actualKeyWidth + 2);
        final actualKeyHeight = widget.keyHeight.clamp(120.0, 200.0);

        Widget keyboardContent = Container(
          width: totalWidth,
          height: actualKeyHeight,
          child: Stack(
            clipBehavior: Clip.none,
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
                    width: actualKeyWidth,
                    height: actualKeyHeight,
                  );
                }).toList(),
              ),
              // Black keys layer (positioned absolutely)
              ...blackNotes.map((note) {
                return Positioned(
                  left: _getBlackKeyOffset(note, actualKeyWidth),
                  top: 0,
                  child: BlackKey(
                    pianoKey: _keys[note]!,
                    onPressed: () => _handleKeyPress(note),
                    onReleased: () => _handleKeyRelease(note),
                    showLabel: widget.showLabels,
                    whiteKeyWidth: actualKeyWidth,
                    whiteKeyHeight: actualKeyHeight,
                  ),
                );
              }),
            ],
          ),
        );

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.grey.shade900, Colors.grey.shade800],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: needsScroll
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: keyboardContent,
                  )
                : Center(child: keyboardContent),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // Don't dispose AudioPlayerService - it's a singleton
    // Just stop any playing sounds
    _audioService.stopAll();
    super.dispose();
  }
}
