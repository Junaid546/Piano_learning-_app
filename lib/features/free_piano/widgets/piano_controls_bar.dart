import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/piano_controller_provider.dart';

/// Premium glassmorphism top control bar for the landscape piano screen.
/// Contains back button, octave selector, volume, settings, record, and sustain controls.
///
/// Features:
/// - Modern glassmorphism design with backdrop blur
/// - Smooth entrance animations
/// - Haptic feedback on interactions
/// - Responsive layout for different screen sizes
/// - Gold accent for active states
class PianoControlsBar extends ConsumerStatefulWidget {
  const PianoControlsBar({super.key});

  @override
  ConsumerState<PianoControlsBar> createState() => _PianoControlsBarState();
}

class _PianoControlsBarState extends ConsumerState<PianoControlsBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _volumeExpanded = false;
  final bool _showRecordButton = false;
  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;

  // Gold color constant for active states
  static const Color _goldColor = Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  void _provideHapticFeedback() {
    HapticFeedback.lightImpact();
  }

  void _onBackPressed() {
    _provideHapticFeedback();
    Navigator.of(context).pop();
  }

  void _onVolumeTap() {
    _provideHapticFeedback();
    setState(() => _volumeExpanded = !_volumeExpanded);
  }

  void _onSettingsPressed() {
    _provideHapticFeedback();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings coming soon')),
    );
  }

  void _onOctaveTap() {
    _provideHapticFeedback();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Octave selector coming soon')),
    );
  }

  void _onRecordPressed() {
    _provideHapticFeedback();
    setState(() {
      _isRecording = !_isRecording;
      if (_isRecording) {
        _recordingDuration = Duration.zero;
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          setState(() {
            _recordingDuration = Duration(seconds: _recordingDuration.inSeconds + 1);
          });
        });
      } else {
        _recordingTimer?.cancel();
      }
    });
  }

  String _formatRecordingTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds % 60)}';
  }

  IconData _getVolumeIcon(double volume, bool isMuted) {
    if (isMuted || volume == 0) return Icons.volume_off;
    if (volume < 0.5) return Icons.volume_down;
    return Icons.volume_up;
  }

  @override
  Widget build(BuildContext context) {
    final pianoState = ref.watch(pianoControllerProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 500;
    final isVerySmallScreen = screenWidth < 380;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: isVerySmallScreen ? 50 : 56,
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // Glassmorphism effect
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.15),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8 : 12,
                vertical: 4,
              ),
              child: Row(
                children: [
                  // Left Section: Back Button
                  _buildBackButton(isSmallScreen),

                  if (!isVerySmallScreen) const SizedBox(width: 12),

                  // Divider
                  if (!isVerySmallScreen)
                    Container(
                      height: 32,
                      width: 1,
                      color: Colors.white.withOpacity(0.2),
                    ),

                  if (!isVerySmallScreen) const SizedBox(width: 12),

                  // Middle Section: Octave Selector
                  _buildOctaveSelector(pianoState, isSmallScreen),

                  const Spacer(),

                  // Right Section: Controls
                  _buildVolumeControl(
                    pianoState.volume,
                    pianoState.isMuted,
                    isVerySmallScreen,
                  ),
                  if (!isVerySmallScreen) const SizedBox(width: 8),
                  _buildSettingsButton(isSmallScreen),
                  if (!isVerySmallScreen) const SizedBox(width: 8),
                  _buildSustainButton(pianoState.sustainEnabled, isSmallScreen),
                  if (!isVerySmallScreen) const SizedBox(width: 8),
                  _buildRecordButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Back Button with glassmorphism style
  Widget _buildBackButton(bool isSmallScreen) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _onBackPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.arrow_back_ios_new,
            size: isSmallScreen ? 18 : 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Octave Selector - Premium Design
  Widget _buildOctaveSelector(PianoControllerState state, bool isSmallScreen) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _onOctaveTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 10 : 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.piano,
                size: isSmallScreen ? 16 : 18,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${state.octaveRange.numOctaves} Octaves',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 11 : 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    state.octaveRange.displayString,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 9 : 10,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.expand_more,
                size: isSmallScreen ? 16 : 18,
                color: Colors.white70,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Volume Control with expandable slider
  Widget _buildVolumeControl(
    double volume,
    bool isMuted,
    bool isVerySmallScreen,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isVerySmallScreen ? 40 : (_volumeExpanded ? 140 : 40),
      height: 40,
      decoration: BoxDecoration(
        color: (_volumeExpanded || isVerySmallScreen)
            ? Colors.white.withOpacity(0.15)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: isVerySmallScreen
          ? IconButton(
              icon: Icon(
                _getVolumeIcon(volume, isMuted),
                size: 18,
                color: Colors.white,
              ),
              onPressed: _onVolumeTap,
              padding: EdgeInsets.zero,
            )
          : (_volumeExpanded
              ? Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _getVolumeIcon(volume, isMuted),
                        size: 18,
                        color: Colors.white,
                      ),
                      onPressed: _onVolumeTap,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: const SliderThemeData(
                          trackHeight: 3,
                          thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          overlayShape: RoundSliderOverlayShape(
                            overlayRadius: 12,
                          ),
                        ),
                        child: Slider(
                          value: isMuted ? 0 : volume,
                          onChanged: (value) => ref
                              .read(pianoControllerProvider.notifier)
                              .setVolume(value),
                          activeColor: Colors.white,
                          inactiveColor: Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                )
              : IconButton(
                  icon: Icon(
                    _getVolumeIcon(volume, isMuted),
                    size: 18,
                    color: Colors.white,
                  ),
                  onPressed: _onVolumeTap,
                )),
    );
  }

  /// Settings Button
  Widget _buildSettingsButton(bool isSmallScreen) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: IconButton(
        icon: Icon(
          Icons.settings,
          size: isSmallScreen ? 18 : 20,
          color: Colors.white,
        ),
        onPressed: _onSettingsPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  /// Sustain Toggle with gold accent
  Widget _buildSustainButton(bool sustainEnabled, bool isSmallScreen) {
    return GestureDetector(
      onTap: () {
        _provideHapticFeedback();
        ref.read(pianoControllerProvider.notifier).toggleSustain();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: sustainEnabled
              ? _goldColor.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: sustainEnabled ? _goldColor : Colors.white.withOpacity(0.2),
            width: sustainEnabled ? 2 : 1,
          ),
          boxShadow: sustainEnabled
              ? [
                  BoxShadow(
                    color: _goldColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Icon(
          Icons.extension,
          size: isSmallScreen ? 18 : 20,
          color: sustainEnabled ? _goldColor : Colors.white,
        ),
      ),
    );
  }

  /// Record Button with timer
  Widget _buildRecordButton() {
    return GestureDetector(
      onTap: _onRecordPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _isRecording ? 72 : 40,
        height: 40,
        decoration: BoxDecoration(
          color: _isRecording
              ? Colors.red.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isRecording ? Colors.red : Colors.white.withOpacity(0.2),
            width: _isRecording ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: _isRecording ? BoxShape.rectangle : BoxShape.circle,
                borderRadius: _isRecording ? BorderRadius.circular(2) : null,
              ),
            ),
            if (_isRecording) ...[
              const SizedBox(width: 6),
              Text(
                _formatRecordingTime(_recordingDuration),
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
