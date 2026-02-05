import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/piano_key.dart';
import '../models/octave_range.dart';
import '../providers/piano_controller_provider.dart';

/// Full piano keyboard widget with support for multiple octaves and scrolling.
/// Optimized for performance with efficient touch handling.
class FullPianoKeyboard extends ConsumerWidget {
  final double width;
  final double height;

  const FullPianoKeyboard({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pianoState = ref.watch(pianoControllerProvider);
    final octaveRange = pianoState.octaveRange;

    // Calculate key dimensions
    final whiteKeyWidth = _calculateWhiteKeyWidth(width, octaveRange);
    final whiteKeyHeight = height * 0.65;
    final blackKeyWidth = whiteKeyWidth * 0.6;
    final blackKeyHeight = whiteKeyHeight * 0.65;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Container(
        width: _calculateTotalKeyboardWidth(whiteKeyWidth, octaveRange),
        height: height,
        color: const Color(0xFF1A1A1A),
        child: Stack(
          children: [
            // White keys
            _buildWhiteKeys(
              octaveRange,
              whiteKeyWidth,
              whiteKeyHeight,
              pianoState,
              ref,
            ),
            // Black keys
            _buildBlackKeys(
              octaveRange,
              whiteKeyWidth,
              blackKeyWidth,
              blackKeyHeight,
              pianoState,
              ref,
            ),
          ],
        ),
      ),
    );
  }

  double _calculateWhiteKeyWidth(double availableWidth, OctaveRange range) {
    final numOctaves = range.numOctaves;
    const minWhiteKeyWidth = 40.0;
    final calculatedWidth = availableWidth / (numOctaves * 7);
    return calculatedWidth.clamp(minWhiteKeyWidth, 70.0);
  }

  double _calculateTotalKeyboardWidth(double whiteKeyWidth, OctaveRange range) {
    return whiteKeyWidth * 7 * range.numOctaves;
  }

  Widget _buildWhiteKeys(
    OctaveRange range,
    double whiteKeyWidth,
    double whiteKeyHeight,
    PianoControllerState state,
    WidgetRef ref,
  ) {
    final children = <Widget>[];

    for (int octave = range.startOctave; octave <= range.endOctave; octave++) {
      for (int i = 0; i < 7; i++) {
        final notes = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
        final note = notes[i];
        final key = PianoKey(note: note, octave: octave);
        final isPressed = state.isKeyActive(note, octave);
        final xOffset = (octave - range.startOctave) * 7 * whiteKeyWidth + i * whiteKeyWidth;

        children.add(
          Positioned(
            left: xOffset,
            top: 0,
            width: whiteKeyWidth,
            height: whiteKeyHeight,
            child: _WhiteKeyWidget(
              pianoKey: key,
              isPressed: isPressed,
              width: whiteKeyWidth,
              showLabel: true,
              onTap: () => ref.read(pianoControllerProvider.notifier).pressKey(note, octave),
              onRelease: () => ref.read(pianoControllerProvider.notifier).releaseKey(note, octave),
            ),
          ),
        );
      }
    }

    return Stack(children: children);
  }

  Widget _buildBlackKeys(
    OctaveRange range,
    double whiteKeyWidth,
    double blackKeyWidth,
    double blackKeyHeight,
    PianoControllerState state,
    WidgetRef ref,
  ) {
    final children = <Widget>[];
    final blackNoteOffsets = {
      'Db': 0,
      'Eb': 1,
      'Gb': 3,
      'Ab': 4,
      'Bb': 5,
    };

    for (int octave = range.startOctave; octave <= range.endOctave; octave++) {
      for (final entry in blackNoteOffsets.entries) {
        final note = entry.key;
        final offset = entry.value;
        final key = PianoKey(note: note, octave: octave);
        final isPressed = state.isKeyActive(note, octave);
        final octaveOffset = (octave - range.startOctave) * 7 * whiteKeyWidth;
        final xOffset = octaveOffset + offset * whiteKeyWidth + whiteKeyWidth * 0.6 - blackKeyWidth / 2;

        children.add(
          Positioned(
            left: xOffset,
            top: 0,
            width: blackKeyWidth,
            height: blackKeyHeight,
            child: _BlackKeyWidget(
              pianoKey: key,
              isPressed: isPressed,
              width: blackKeyWidth,
              showLabel: true,
              onTap: () => ref.read(pianoControllerProvider.notifier).pressKey(note, octave),
              onRelease: () => ref.read(pianoControllerProvider.notifier).releaseKey(note, octave),
            ),
          ),
        );
      }
    }

    return Stack(children: children);
  }
}

/// Individual white key widget with animation support.
class _WhiteKeyWidget extends StatefulWidget {
  final PianoKey pianoKey;
  final bool isPressed;
  final double width;
  final bool showLabel;
  final VoidCallback onTap;
  final VoidCallback onRelease;

  const _WhiteKeyWidget({
    required this.pianoKey,
    required this.isPressed,
    required this.width,
    required this.showLabel,
    required this.onTap,
    required this.onRelease,
  });

  @override
  State<_WhiteKeyWidget> createState() => _WhiteKeyWidgetState();
}

class _WhiteKeyWidgetState extends State<_WhiteKeyWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(_WhiteKeyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPressed != oldWidget.isPressed) {
      if (widget.isPressed) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => widget.onTap(),
      onTapUp: (_) => widget.onRelease(),
      onTapCancel: widget.onRelease,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: widget.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: widget.isPressed
                  ? [
                      const Color(0xFF7C4DFF),
                      const Color(0xFFFF4081),
                    ]
                  : [
                      Colors.white,
                      const Color(0xFFF5F5F5),
                    ],
            ),
            border: Border(
              right: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            boxShadow: widget.isPressed
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: widget.showLabel
              ? Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      widget.pianoKey.note,
                      style: TextStyle(
                        color: widget.isPressed ? Colors.white : Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

/// Individual black key widget with animation support.
class _BlackKeyWidget extends StatefulWidget {
  final PianoKey pianoKey;
  final bool isPressed;
  final double width;
  final bool showLabel;
  final VoidCallback onTap;
  final VoidCallback onRelease;

  const _BlackKeyWidget({
    required this.pianoKey,
    required this.isPressed,
    required this.width,
    required this.showLabel,
    required this.onTap,
    required this.onRelease,
  });

  @override
  State<_BlackKeyWidget> createState() => _BlackKeyWidgetState();
}

class _BlackKeyWidgetState extends State<_BlackKeyWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(_BlackKeyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPressed != oldWidget.isPressed) {
      if (widget.isPressed) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => widget.onTap(),
      onTapUp: (_) => widget.onRelease(),
      onTapCancel: widget.onRelease,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: widget.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: widget.isPressed
                  ? [
                      const Color(0xFFFFD700).withOpacity(0.9),
                      const Color(0xFFFFD700).withOpacity(0.7),
                    ]
                  : [
                      const Color(0xFF2A2A2A),
                      const Color(0xFF1A1A1A),
                    ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(3),
              bottomRight: Radius.circular(3),
            ),
            boxShadow: widget.isPressed
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: widget.showLabel
              ? Center(
                  child: Text(
                    widget.pianoKey.note,
                    style: TextStyle(
                      color: widget.isPressed ? Colors.black : Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
