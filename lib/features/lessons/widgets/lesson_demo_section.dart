import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
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
    // Initialize audio service asynchronously
    _audioService.initialize();
  }

  Future<void> _playDemo() async {
    if (_isPlaying) return;

    // Ensure audio service is initialized before playing
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

      // Wait based on playback speed
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
    // Map note strings to Note objects
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.headphones, color: AppColors.infoBlue, size: 24),
              const SizedBox(width: 12),
              Text(
                'Watch & Listen',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Notes display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.demoNotes.asMap().entries.map((entry) {
                final index = entry.key;
                final note = entry.value;
                final isActive = index == _currentNoteIndex;

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primaryPurple : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isActive
                          ? AppColors.primaryPurple
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    note,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isActive
                          ? Colors.white
                          : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Controls
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isPlaying ? _stopDemo : _playDemo,
                  icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                  label: Text(_isPlaying ? 'Stop' : 'Play Demo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isPlaying
                        ? Colors.red
                        : AppColors.infoBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Speed control
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<double>(
                  value: _playbackSpeed,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 0.5, child: Text('0.5x')),
                    DropdownMenuItem(value: 0.75, child: Text('0.75x')),
                    DropdownMenuItem(value: 1.0, child: Text('1x')),
                    DropdownMenuItem(value: 1.5, child: Text('1.5x')),
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
    // Don't dispose AudioPlayerService - it's a singleton!
    // Just stop any playing sounds
    _audioService.stopAll();
    super.dispose();
  }
}
