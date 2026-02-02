import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/piano_controller_provider.dart';
import '../models/octave_range.dart';

/// Premium glass morphism control bar for the landscape piano screen.
class PremiumControlsBar extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onSettings;
  final VoidCallback onRecord;
  final VoidCallback onOctaveTap;
  final bool showLabels;

  const PremiumControlsBar({
    super.key,
    required this.onBack,
    required this.onSettings,
    required this.onRecord,
    required this.onOctaveTap,
    this.showLabels = true,
  });

  @override
  ConsumerState<PremiumControlsBar> createState() => _PremiumControlsBarState();
}

class _PremiumControlsBarState extends ConsumerState<PremiumControlsBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _volumeController;
  bool _volumeExpanded = false;
  double _previousVolume = 0.8;

  @override
  void initState() {
    super.initState();
    _volumeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _volumeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pianoState = ref.watch(pianoControllerProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.05),
                ]
              : [
                  Colors.black.withOpacity(0.08),
                  Colors.black.withOpacity(0.05),
                ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(isDarkMode ? 0.12 : 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          _buildGlassButton(
            icon: Icons.arrow_back,
            onPressed: widget.onBack,
            tooltip: 'Exit Free Play',
          ),

          const SizedBox(width: 8),

          // Octave selector
          _buildOctaveSelector(pianoState.octaveRange),

          const Spacer(),

          // Title
          Text(
            'Free Play',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),

          const Spacer(),

          // Right side controls
          Row(
            children: [
              // Volume control
              _buildVolumeControl(pianoState),

              const SizedBox(width: 4),

              // Settings
              _buildGlassButton(
                icon: Icons.settings,
                onPressed: widget.onSettings,
                tooltip: 'Settings',
              ),

              const SizedBox(width: 4),

              // Record
              _buildRecordButton(false),

              const SizedBox(width: 4),

              // Sustain
              _buildSustainButton(pianoState.sustainEnabled),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white.withOpacity(0.05),
          ),
          child: Icon(
            icon,
            color: Colors.white.withOpacity(0.8),
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildOctaveSelector(OctaveRange range) {
    return GestureDetector(
      onTap: widget.onOctaveTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withOpacity(0.08),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.piano,
              color: Colors.white.withOpacity(0.7),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              range.displayString,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeControl(PianoControllerState state) {
    return AnimatedBuilder(
      animation: _volumeController,
      builder: (context, child) {
        final width = _volumeExpanded ? 120.0 : 40.0;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _volumeExpanded = !_volumeExpanded;
              if (_volumeExpanded) {
                _volumeController.forward();
              } else {
                _volumeController.reverse();
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: width + 20,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(0.05),
            ),
            child: Row(
              children: [
                SizedBox(width: _volumeExpanded ? 8 : 12),
                Icon(
                  state.isMuted
                      ? Icons.volume_off
                      : state.volume < 0.5
                          ? Icons.volume_down
                          : Icons.volume_up,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
                if (_volumeExpanded) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Slider(
                      value: state.volume,
                      onChanged: (value) {
                        ref.read(pianoControllerProvider.notifier).setVolume(value);
                      },
                      activeColor: const Color(0xFF7C4DFF),
                      inactiveColor: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecordButton(bool isRecording) {
    return GestureDetector(
      onTap: widget.onRecord,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isRecording
              ? Colors.red.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: isRecording
                ? Colors.red.withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.fiber_manual_record,
              color: isRecording ? Colors.red : Colors.white.withOpacity(0.7),
              size: 16,
            ),
            if (isRecording)
              AnimatedBuilder(
                animation: const AlwaysStoppedAnimation(0),
                builder: (context, child) {
                  return Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.5),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSustainButton(bool isEnabled) {
    return GestureDetector(
      onTap: () {
        ref.read(pianoControllerProvider.notifier).toggleSustain();
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isEnabled
              ? Colors.amber.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: isEnabled
                ? Colors.amber.withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Icon(
          Icons.pedal_bike,
          color: isEnabled
              ? Colors.amber
              : Colors.white.withOpacity(0.5),
          size: 20,
        ),
      ),
    );
  }
}

/// Premium toggle switch widget.
class PremiumToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color inactiveColor;

  const PremiumToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = const Color(0xFF7C4DFF),
    this.inactiveColor = Colors.white24,
  });

  @override
  State<PremiumToggle> createState() => _PremiumToggleState();
}

class _PremiumToggleState extends State<PremiumToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _toggleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _toggleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(PremiumToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onChanged(!widget.value);
        HapticFeedback.lightImpact();
      },
      child: AnimatedBuilder(
        animation: _toggleAnimation,
        builder: (context, child) {
          return Container(
            width: 51,
            height: 31,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: widget.value
                  ? widget.activeColor
                  : widget.inactiveColor,
              boxShadow: widget.value
                  ? [
                      BoxShadow(
                        color: widget.activeColor.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 2 + _toggleAnimation.value * 18,
                  top: 2,
                  child: Container(
                    width: 27,
                    height: 27,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Premium slider widget with gradient track.
class PremiumSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final Color activeColor;
  final Color inactiveColor;

  const PremiumSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.activeColor = const Color(0xFF7C4DFF),
    this.inactiveColor = Colors.white24,
  });

  @override
  State<PremiumSlider> createState() => _PremiumSliderState();
}

class _PremiumSliderState extends State<PremiumSlider> {
  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 4,
        activeTrackColor: widget.activeColor,
        inactiveTrackColor: widget.inactiveColor,
        thumbColor: Colors.white,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 10,
          elevation: 2,
        ),
        overlayColor: widget.activeColor.withOpacity(0.2),
        overlayShape: const RoundSliderOverlayShape(
          overlayRadius: 16,
        ),
      ),
      child: Slider(
        value: widget.value,
        onChanged: widget.onChanged,
        min: widget.min,
        max: widget.max,
      ),
    );
  }
}

/// Premium dropdown selector widget.
class PremiumDropdown extends StatefulWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final String label;

  const PremiumDropdown({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.label,
  });

  @override
  State<PremiumDropdown> createState() => _PremiumDropdownState();
}

class _PremiumDropdownState extends State<PremiumDropdown> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isOpen = !_isOpen;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withOpacity(0.05),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
          ),
        ),
        child: Row(
          children: [
            Text(
              widget.label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            AnimatedRotation(
              turns: _isOpen ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white.withOpacity(0.5),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
