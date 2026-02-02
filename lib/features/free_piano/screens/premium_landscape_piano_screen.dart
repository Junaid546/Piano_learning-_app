import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/piano_key.dart';
import '../models/octave_range.dart';
import '../providers/piano_controller_provider.dart';
import '../widgets/premium_background.dart' as bg;
import '../widgets/premium_visualizer.dart';
import '../widgets/premium_piano_keys.dart';
import '../widgets/premium_modals.dart';
import '../widgets/premium_controls_bar.dart' as controls;

/// Ultra-premium landscape piano screen with photorealistic keys and stunning visuals.
/// Fixed with proper multi-touch handling and overflow protection.
class PremiumLandscapePianoScreen extends ConsumerStatefulWidget {
  const PremiumLandscapePianoScreen({super.key});

  @override
  ConsumerState<PremiumLandscapePianoScreen> createState() =>
      _PremiumLandscapePianoScreenState();
}

class _PremiumLandscapePianoScreenState
    extends ConsumerState<PremiumLandscapePianoScreen>
    with WidgetsBindingObserver {
  bool _orientationLocked = false;
  
  // Track active pointer IDs for multi-touch
  final Map<int, String> _activePointers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lockOrientation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _restoreOrientation();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _lockOrientation();
    }
  }

  Future<void> _lockOrientation() async {
    if (_orientationLocked) return;

    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      _orientationLocked = true;
    } catch (e) {
      debugPrint('Error locking orientation: $e');
    }
  }

  Future<void> _restoreOrientation() async {
    if (!_orientationLocked) return;

    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      );
      _orientationLocked = false;
    } catch (e) {
      debugPrint('Error restoring orientation: $e');
    }
  }

  Future<bool> _onWillPop() async {
    // Restore orientation in background
    _restoreOrientation();
    return true;
  }

  void _handlePointerDown(PointerDownEvent event, OctaveRange range, double whiteKeyWidth, double screenHeight) {
    final position = event.localPosition;
    final keyId = _findKeyAtPosition(position, range, whiteKeyWidth, screenHeight);
    
    if (keyId != null) {
      _activePointers[event.pointer] = keyId;
      
      // Parse key ID
      final match = RegExp(r'([A-Gb]+)(\d+)').firstMatch(keyId);
      if (match != null) {
        final note = match.group(1)!;
        final octave = int.parse(match.group(2)!);
        ref.read(pianoControllerProvider.notifier).pressKey(note, octave);
      }
    }
  }

  String? _findKeyAtPosition(
    Offset position,
    OctaveRange range,
    double whiteKeyWidth,
    double screenHeight,
  ) {
    // Check black keys first (they're on top)
    final blackKeyWidth = whiteKeyWidth * 0.6;
    final blackKeyHeight = screenHeight * 0.65 * 0.65;
    
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
        final octaveOffset = (octave - range.startOctave) * 7 * whiteKeyWidth;
        final xOffset = octaveOffset + offset * whiteKeyWidth + whiteKeyWidth * 0.6 - blackKeyWidth / 2;
        
        // Check if position is within black key bounds
        if (position.dx >= xOffset - 1 && 
            position.dx <= xOffset + blackKeyWidth + 1 &&
            position.dy >= 0 && 
            position.dy <= blackKeyHeight) {
          return '$note$octave';
        }
      }
    }

    // Check white keys
    final whiteKeyHeight = screenHeight * 0.65;
    final notes = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
    
    for (int octave = range.startOctave; octave <= range.endOctave; octave++) {
      for (int i = 0; i < 7; i++) {
        final note = notes[i];
        final xOffset = (octave - range.startOctave) * 7 * whiteKeyWidth + i * whiteKeyWidth;
        
        // Check if position is within white key bounds
        if (position.dx >= xOffset - 1 && 
            position.dx <= xOffset + whiteKeyWidth + 1 &&
            position.dy >= 0 && 
            position.dy <= whiteKeyHeight) {
          return '$note$octave';
        }
      }
    }

    return null;
  }

  void _handlePointerUp(PointerUpEvent event) {
    final keyId = _activePointers.remove(event.pointer);
    if (keyId != null) {
      final match = RegExp(r'([A-Gb]+)(\d+)').firstMatch(keyId);
      if (match != null) {
        final note = match.group(1)!;
        final octave = int.parse(match.group(2)!);
        ref.read(pianoControllerProvider.notifier).releaseKey(note, octave);
      }
    }
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    _activePointers.remove(event.pointer);
  }

  void _handlePointerHover(PointerHoverEvent event) {
    // Desktop hover - no action needed for touch devices
  }

  void _handlePointerMove(PointerMoveEvent event) {
    final position = event.localPosition;
    final octaveRange = ref.read(pianoControllerProvider).octaveRange;
    final whiteKeyWidth = (MediaQuery.of(context).size.width / (octaveRange.numOctaves * 7)).clamp(40.0, 70.0);
    final screenHeight = MediaQuery.of(context).size.height;
    
    final newKeyId = _findKeyAtPosition(position, octaveRange, whiteKeyWidth, screenHeight);
    final currentKeyId = _activePointers[event.pointer];
    
    // If moved to a different key, switch notes
    if (newKeyId != null && newKeyId != currentKeyId) {
      // Release old key if it exists
      if (currentKeyId != null) {
        _releaseKey(currentKeyId);
      }
      
      // Press new key
      _activePointers[event.pointer] = newKeyId;
      _pressKey(newKeyId);
    }
    
    // If moved outside keyboard area, release the key
    if (newKeyId == null && currentKeyId != null) {
      _releaseKey(currentKeyId);
      _activePointers.remove(event.pointer);
    }
  }

  void _pressKey(String keyId) {
    final match = RegExp(r'([A-Gb]+)(\d+)').firstMatch(keyId);
    if (match != null) {
      final note = match.group(1)!;
      final octave = int.parse(match.group(2)!);
      ref.read(pianoControllerProvider.notifier).pressKey(note, octave);
    }
  }

  void _releaseKey(String keyId) {
    final match = RegExp(r'([A-Gb]+)(\d+)').firstMatch(keyId);
    if (match != null) {
      final note = match.group(1)!;
      final octave = int.parse(match.group(2)!);
      ref.read(pianoControllerProvider.notifier).releaseKey(note, octave);
    }
  }

  void _showOctaveSelector() {
    showOctaveSelectorModal(context, (OctaveRange range) {
      ref.read(pianoControllerProvider.notifier).setOctaveRange(
        range.startOctave,
        range.numOctaves,
      );
    });
  }

  void _showSettings() {
    showSettingsPanel(context);
  }

  void _handleBack(BuildContext context) {
    // Navigate FIRST while still in landscape mode
    // Orientation restoration will happen in dispose() automatically
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      GoRouter.of(context).go('/');
    }
  }

  void _handleRecord() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recording coming soon'),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pianoState = ref.watch(pianoControllerProvider);
    final octaveRange = pianoState.octaveRange;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: bg.PremiumBackground(
        showParticles: true,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final availableHeight = constraints.maxHeight;
                
                // Calculate key dimensions
                final whiteKeyWidth = (availableWidth / (octaveRange.numOctaves * 7)).clamp(40.0, 70.0);
                final whiteKeyHeight = availableHeight * 0.65;
                final blackKeyWidth = whiteKeyWidth * 0.6;
                final blackKeyHeight = whiteKeyHeight * 0.65;
                final totalWidth = whiteKeyWidth * 7 * octaveRange.numOctaves;

                return Column(
                  children: [
                    // Premium control bar
                    controls.PremiumControlsBar(
                      onBack: () => _handleBack(context),
                      onSettings: _showSettings,
                      onRecord: _handleRecord,
                      onOctaveTap: _showOctaveSelector,
                    ),

                    // Premium visualizer
                    const PremiumVisualizer(
                      height: 70,
                      enabled: true,
                    ),

                    // Main content - premium piano keyboard with multi-touch
                    Expanded(
                      child: RepaintBoundary(
                        child: Listener(
                          onPointerDown: (event) => _handlePointerDown(
                            event, octaveRange, whiteKeyWidth, availableHeight,
                          ),
                          onPointerMove: _handlePointerMove,
                          onPointerUp: _handlePointerUp,
                          onPointerCancel: _handlePointerCancel,
                          onPointerHover: _handlePointerHover,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const ClampingScrollPhysics(),
                            child: SizedBox(
                              width: totalWidth,
                              height: availableHeight,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // White keys
                                  _buildWhiteKeys(
                                    octaveRange,
                                    whiteKeyWidth,
                                    whiteKeyHeight,
                                    pianoState,
                                  ),
                                  // Black keys
                                  _buildBlackKeys(
                                    octaveRange,
                                    whiteKeyWidth,
                                    blackKeyWidth,
                                    blackKeyHeight,
                                    pianoState,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWhiteKeys(
    OctaveRange range,
    double whiteKeyWidth,
    double whiteKeyHeight,
    PianoControllerState state,
  ) {
    final children = <Widget>[];

    for (int octave = range.startOctave; octave <= range.endOctave; octave++) {
      for (int i = 0; i < 7; i++) {
        final notes = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
        final note = notes[i];
        final isPressed = state.isKeyActive(note, octave);
        final xOffset = (octave - range.startOctave) * 7 * whiteKeyWidth + i * whiteKeyWidth;

        children.add(
          Positioned(
            left: xOffset,
            top: 0,
            width: whiteKeyWidth,
            height: whiteKeyHeight,
            child: IgnorePointer(
              child: PremiumWhiteKey(
                pianoKey: PianoKey(note: note, octave: octave),
                isPressed: isPressed,
                width: whiteKeyWidth,
                height: whiteKeyHeight,
                showLabel: true,
                touchPosition: null,
                onTap: () {},
                onRelease: () {},
              ),
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
        final isPressed = state.isKeyActive(note, octave);
        final octaveOffset = (octave - range.startOctave) * 7 * whiteKeyWidth;
        final xOffset = octaveOffset + offset * whiteKeyWidth + whiteKeyWidth * 0.6 - blackKeyWidth / 2;

        children.add(
          Positioned(
            left: xOffset,
            top: 0,
            width: blackKeyWidth,
            height: blackKeyHeight,
            child: IgnorePointer(
              child: PremiumBlackKey(
                pianoKey: PianoKey(note: note, octave: octave),
                isPressed: isPressed,
                width: blackKeyWidth,
                height: blackKeyHeight,
                showLabel: true,
                touchPosition: null,
                onTap: () {},
                onRelease: () {},
              ),
            ),
          ),
        );
      }
    }

    return Stack(children: children);
  }
}
