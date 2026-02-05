import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/glass_container.dart';
import '../../piano/models/note.dart';
import '../../piano/services/audio_player_service.dart';

class LessonDemoSection extends StatefulWidget {
  final List<String> demoNotes;

  const LessonDemoSection({super.key, required this.demoNotes});

  @override
  State<LessonDemoSection> createState() => _LessonDemoSectionState();
}

class _LessonDemoSectionState extends State<LessonDemoSection> {
  final AudioPlayerService _audioService = AudioPlayerService();
  bool _isPlaying = false;
  int _currentNoteIndex = -1;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _audioService.initialize();
  }

  Future<void> _playDemo() async {
    if (_isPlaying) return;

    if (!_audioService.isInitialized) {
      await _audioService.initialize();
    }

    setState(() => _isPlaying = true);

    for (int i = 0; i < widget.demoNotes.length; i++) {
      if (!_isPlaying) break;

      setState(() => _currentNoteIndex = i);

      final noteStr = widget.demoNotes[i];
      final note = _getNoteFromString(noteStr);

      if (note != null) {
        _audioService.playNote(note);
      }

      await Future.delayed(
        Duration(milliseconds: (800 / _playbackSpeed).round()),
      );
    }

    setState(() {
      _isPlaying = false;
      _currentNoteIndex = -1;
    });
  }

  void _stopDemo() {
    setState(() {
      _isPlaying = false;
      _currentNoteIndex = -1;
    });
    _audioService.stopAll();
  }

  Note? _getNoteFromString(String noteStr) {
    final noteMap = {
      'C4': Note.c4,
      'Db4': Note.cSharp4,
      'D4': Note.d4,
      'Eb4': Note.dSharp4,
      'E4': Note.e4,
      'F4': Note.f4,
      'Gb4': Note.fSharp4,
      'G4': Note.g4,
      'Ab4': Note.gSharp4,
      'A4': Note.a4,
      'Bb4': Note.aSharp4,
      'B4': Note.b4,
      'C5': Note.c5,
      'Db5': Note.cSharp5,
      'D5': Note.d5,
      'Eb5': Note.dSharp5,
      'E5': Note.e5,
      'F5': Note.f5,
      'Gb5': Note.fSharp5,
      'G5': Note.g5,
      'Ab5': Note.gSharp5,
      'A5': Note.a5,
      'Bb5': Note.aSharp5,
      'B5': Note.b5,
    };
    return noteMap[noteStr];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return GlassContainer(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      opacity: isDark ? 0.12 : 0.08,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.infoBlue.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.headphones, color: AppColors.infoBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Watch & Listen',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.infoBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${_playbackSpeed}x',
                  style: const TextStyle(
                    color: AppColors.infoBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Notes display
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.infoBlue.withOpacity(0.15),
              ),
            ),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: widget.demoNotes.asMap().entries.map((entry) {
                final index = entry.key;
                final note = entry.value;
                final isActive = index == _currentNoteIndex;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.infoBlue : surfaceColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isActive ? AppColors.infoBlue : AppColors.infoBlue.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    note,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isActive ? Colors.white : textPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          // Controls
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _isPlaying ? _stopDemo : _playDemo,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: _isPlaying
                          ? const LinearGradient(colors: [AppColors.errorRed, Color(0xFFFF5252)])
                          : const LinearGradient(colors: [AppColors.infoBlue, Color(0xFF64B5F6)]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isPlaying ? Icons.stop : Icons.play_arrow,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isPlaying ? 'Stop' : 'Play Demo',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Speed dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<double>(
                  value: _playbackSpeed,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.speed, color: AppColors.infoBlue, size: 16),
                  dropdownColor: surfaceColor,
                  items: const [
                    DropdownMenuItem(value: 0.5, child: Text('0.5x', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 0.75, child: Text('0.75x', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 1.0, child: Text('1x', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                    DropdownMenuItem(value: 1.5, child: Text('1.5x', style: TextStyle(fontSize: 12))),
                  ],
                  onChanged: (value) {
                    setState(() => _playbackSpeed = value ?? 1.0);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioService.stopAll();
    super.dispose();
  }
}
