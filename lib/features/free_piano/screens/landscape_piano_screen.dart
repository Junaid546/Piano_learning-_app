import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/piano_controller_provider.dart';
import '../widgets/piano_controls_bar.dart';
import '../widgets/full_piano_keyboard.dart';
import '../widgets/sound_visualizer.dart';

/// Full-screen landscape piano playing screen.
/// Forces landscape orientation and immersive mode for optimal piano experience.
class LandscapePianoScreen extends ConsumerStatefulWidget {
  const LandscapePianoScreen({super.key});

  @override
  ConsumerState<LandscapePianoScreen> createState() =>
      _LandscapePianoScreenState();
}

class _LandscapePianoScreenState extends ConsumerState<LandscapePianoScreen>
    with WidgetsBindingObserver {
  // Track whether we've locked orientation
  bool _orientationLocked = false;

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
      // Re-apply orientation lock when app resumes
      _lockOrientation();
    }
  }

  /// Lock orientation to landscape and enable immersive mode
  Future<void> _lockOrientation() async {
    if (_orientationLocked) return;

    try {
      // Set landscape orientations only
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

      // Enable immersive sticky mode (hides status and navigation bars)
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

      _orientationLocked = true;
    } catch (e) {
      // Handle any errors silently
      debugPrint('Error locking orientation: $e');
    }
  }

  /// Restore original orientations
  Future<void> _restoreOrientation() async {
    if (!_orientationLocked) return;

    try {
      // Restore to default orientations (both portrait and landscape)
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      _orientationLocked = false;
    } catch (e) {
      debugPrint('Error restoring orientation: $e');
    }
  }

  /// Handle back button press
  Future<bool> _onWillPop() async {
    await _restoreOrientation();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        // No app bar - we have our own control bar
        body: SafeArea(
          // Use SafeArea to avoid system UI overlap
          child: Container(
            // Dark gradient background for professional piano look
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDarkMode
                    ? [
                        const Color(0xFF0D0D0D),
                        const Color(0xFF1A1A2E),
                        const Color(0xFF16213E),
                      ]
                    : [
                        const Color(0xFF1A1A2E),
                        const Color(0xFF0D0D0D),
                      ],
              ),
            ),
            child: Column(
              children: [
                // Top control bar
                const PianoControlsBar(),

                // Sound visualizer (optional, between controls and keyboard)
                const SoundVisualizer(
                  height: 80,
                  enabled: true,
                ),

                // Main content - piano keyboard
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate optimal keyboard dimensions
                      final availableWidth = constraints.maxWidth;
                      final availableHeight = constraints.maxHeight;

                      return FullPianoKeyboard(
                        width: availableWidth,
                        height: availableHeight,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
