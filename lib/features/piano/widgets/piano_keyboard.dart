import 'package:flutter/material.dart';

// Core models and services
import '../models/note.dart';
import '../models/piano_key.dart';
import '../services/audio_player_service.dart';

// Piano key widgets
import 'white_key.dart';
import 'black_key.dart';

/// A responsive piano keyboard widget that handles overflow gracefully.
///
/// This widget renders an interactive piano with:
/// - Configurable number of octaves
/// - Support for note highlighting (for lessons/practice)
/// - Audio feedback on key press
/// - Responsive design with horizontal scrolling
/// - Proper layering of black keys over white keys
///
/// ## Usage Example:
/// ```dart
/// PianoKeyboard(
///   numberOfOctaves: 2,
///   showLabels: true,
///   highlightedNotes: [Note.c4, Note.e4, Note.g4],
///   enableSound: true,
///   onNotePlayed: (note) => print('Played: ${note.fullName}'),
/// )
/// ```
class PianoKeyboard extends StatefulWidget {
  /// Number of octaves to display (default: 1)
  final int numberOfOctaves;

  /// Whether to show note labels on keys (default: true)
  final bool showLabels;

  /// List of notes to highlight (for lesson guidance)
  final List<Note>? highlightedNotes;

  /// Callback when a note is played
  ///
  /// This is called regardless of whether audio is enabled.
  /// Use this for tracking user input, lesson progress, etc.
  final Function(Note)? onNotePlayed;

  /// Whether to play sound on key press (default: true)
  final bool enableSound;

  /// Width of each white key in logical pixels (default: 45)
  final double keyWidth;

  /// Height of keys in logical pixels (default: 160)
  final double keyHeight;

  /// Creates a new piano keyboard widget.
  ///
  /// [numberOfOctaves] controls how many octaves are displayed.
  /// [highlightedNotes] can be used to highlight specific notes (e.g., for
  /// showing which notes to press in a lesson).
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

/// State for the PianoKeyboard widget.
///
/// Manages:
/// - Audio service initialization and playback
/// - Key press/release state tracking
/// - Responsive layout calculations
/// - Note highlighting updates
class _PianoKeyboardState extends State<PianoKeyboard> {
  /// Singleton audio service for playback
  final AudioPlayerService _audioService = AudioPlayerService();

  /// Map of notes to their corresponding key widgets
  final Map<Note, PianoKey> _keys = {};

  /// Set of currently pressed notes (for visual feedback)
  final Set<Note> _pressedNotes = {};

  /// Whether audio has been initialized
  bool _audioInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize all piano keys for the configured octaves
    _initializeKeys();
    // Initialize audio service (non-blocking)
    _initAudio();
  }

  /// Initialize audio service if enabled and not already initialized.
  Future<void> _initAudio() async {
    if (widget.enableSound && !_audioInitialized) {
      await _audioService.initialize();
      _audioInitialized = true;
    }
  }

  /// Creates piano key widgets for all notes in the configured octaves.
  ///
  /// Each note gets a [PianoKey] object that holds its state
  /// (pressed, highlighted, etc.).
  void _initializeKeys() {
    _keys.clear();
    // Start from octave 4 (middle C) and add configured number of octaves
    for (int octave = 4; octave < 4 + widget.numberOfOctaves; octave++) {
      final notes = Note.getOctave(octave);
      for (final note in notes) {
        _keys[note] = PianoKey(
          note: note,
          // Highlight if this note is in the highlightedNotes list
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
    // Update highlights if the highlightedNotes list changed
    if (oldWidget.highlightedNotes != widget.highlightedNotes) {
      _updateHighlights();
    }
    // Re-initialize keys if the number of octaves changed
    if (oldWidget.numberOfOctaves != widget.numberOfOctaves) {
      _initializeKeys();
    }
  }

  /// Updates the highlight state for all keys based on highlightedNotes.
  void _updateHighlights() {
    setState(() {
      for (final entry in _keys.entries) {
        final isHighlighted =
            widget.highlightedNotes?.contains(entry.key) ?? false;
        _keys[entry.key] = entry.value.copyWith(
          isHighlighted: isHighlighted,
          highlightColor: isHighlighted ? Colors.blue : null,
          // Remove highlight color when not highlighted
          clearHighlightColor: !isHighlighted,
        );
      }
    });
  }

  /// Handles the initial press of a piano key.
  ///
  /// This method:
  /// 1. Updates the visual state (pressed appearance)
  /// 2. Plays the note audio if enabled
  /// 3. Calls the onNotePlayed callback
  void _handleKeyPress(Note note) {
    if (!mounted) return; // Guard against disposed widget

    setState(() {
      _pressedNotes.add(note);
      _keys[note] = _keys[note]!.copyWith(isPressed: true);
    });

    // Play audio if enabled
    if (widget.enableSound) {
      _audioService.playNote(note);
    }

    // Notify listener
    widget.onNotePlayed?.call(note);
  }

  /// Handles the release of a piano key.
  ///
  /// This only updates the visual state - the audio naturally
  /// stops when the note's release mode ends.
  void _handleKeyRelease(Note note) {
    if (!mounted) return; // Guard against disposed widget

    setState(() {
      _pressedNotes.remove(note);
      _keys[note] = _keys[note]!.copyWith(isPressed: false);
    });
  }

  /// Gets all white (natural) notes from the keyboard.
  List<Note> _getWhiteNotes() {
    return _keys.keys.where((note) => !note.isSharp).toList();
  }

  /// Gets all black (sharp/flat) notes from the keyboard.
  List<Note> _getBlackNotes() {
    return _keys.keys.where((note) => note.isSharp).toList();
  }

  /// Calculates the horizontal offset for a black key.
  ///
  /// Black keys are positioned between white keys according to
  /// the standard piano layout:
  /// - C# is between C and D
  /// - D# is between D and E
  /// - No black key between E and F
  /// - F# is between F and G
  /// - G# is between G and A
  /// - A# is between A and B
  /// - No black key between B and C
  ///
  /// [blackNote] The black note to position
  /// [actualKeyWidth] The actual rendered width of white keys
  double _getBlackKeyOffset(Note blackNote, double actualKeyWidth) {
    final whiteNotes = _getWhiteNotes();
    final noteName = blackNote.noteName;
    final octave = blackNote.octave;

    // Find the white key that comes immediately before this black key
    // This determines the horizontal position
    int whiteKeyIndex = 0;
    if (noteName == 'C') {
      // C# is between C and D
      whiteKeyIndex = whiteNotes.indexWhere(
        (n) => n.noteName == 'C' && n.octave == octave,
      );
    } else if (noteName == 'D') {
      // D# is between D and E
      whiteKeyIndex = whiteNotes.indexWhere(
        (n) => n.noteName == 'D' && n.octave == octave,
      );
    } else if (noteName == 'F') {
      // F# is between F and G
      whiteKeyIndex = whiteNotes.indexWhere(
        (n) => n.noteName == 'F' && n.octave == octave,
      );
    } else if (noteName == 'G') {
      // G# is between G and A
      whiteKeyIndex = whiteNotes.indexWhere(
        (n) => n.noteName == 'G' && n.octave == octave,
      );
    } else if (noteName == 'A') {
      // A# is between A and B
      whiteKeyIndex = whiteNotes.indexWhere(
        (n) => n.noteName == 'A' && n.octave == octave,
      );
    }

    // Fallback to first key if not found
    if (whiteKeyIndex < 0) whiteKeyIndex = 0;

    // Calculate position: centered between the two white keys
    // Black key width is 60% of white key width
    final whiteKeyWidthWithMargin = actualKeyWidth + 2; // +2 for gap
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
        // Account for horizontal padding
        final availableWidth = constraints.maxWidth - 40;
        // Ideal width if we used the configured keyWidth
        final idealTotalWidth = whiteNotes.length * (widget.keyWidth + 2);

        // Use scrolling if content is wider than available space
        final needsScroll = idealTotalWidth > availableWidth;
        // If scrolling, use configured width; otherwise fill available space
        final actualKeyWidth = needsScroll
            ? widget.keyWidth
            : (availableWidth / whiteNotes.length) - 2;

        // Calculate total keyboard width
        final totalWidth = whiteNotes.length * (actualKeyWidth + 2);
        // Clamp height to reasonable bounds
        final actualKeyHeight = widget.keyHeight.clamp(120.0, 200.0);

        // Build the keyboard content
        Widget keyboardContent = SizedBox(
          width: totalWidth,
          height: actualKeyHeight,
          child: Stack(
            clipBehavior: Clip.none, // Allow black keys to overlap white keys
            children: [
              // Layer 1: White keys (rendered in a row)
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
              // Layer 2: Black keys (positioned absolutely over white keys)
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

        // Wrap with container for styling and optional scrolling
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
    // Don't dispose AudioPlayerService - it's a singleton managed elsewhere
    // Just stop any currently playing sounds
    _audioService.stopAll();
    super.dispose();
  }
}
