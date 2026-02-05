import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/glass_container.dart';
import '../models/lesson.dart';
import '../providers/lessons_provider.dart';
import '../widgets/lesson_theory_section.dart';
import '../widgets/lesson_demo_section.dart';
import '../../piano/widgets/piano_keyboard.dart';
import '../../piano/models/note.dart';

class LessonDetailScreen extends ConsumerStatefulWidget {
  final Lesson lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  @override
  ConsumerState<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen> {
  final List<String> _playedNotes = [];
  bool _practiceCompleted = false;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _handleNotePlayed(Note note) {
    setState(() {
      _playedNotes.add(note.fullName);

      if (_playedNotes.length >= widget.lesson.content.practiceNotes.length) {
        _checkPracticeCompletion();
      }
    });
  }

  void _checkPracticeCompletion() {
    final practiceNotes = widget.lesson.content.practiceNotes;
    bool allCorrect = true;

    for (int i = 0; i < practiceNotes.length; i++) {
      if (i >= _playedNotes.length || _playedNotes[i] != practiceNotes[i]) {
        allCorrect = false;
        break;
      }
    }

    if (allCorrect) {
      setState(() => _practiceCompleted = true);
      _confettiController.play();
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: GlassContainer(
          opacity: 0.15,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/lottie/Success.json',
                  height: 100,
                  repeat: false,
                ),
                const SizedBox(height: 16),
                Text(
                  '🎉 Amazing!',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [AppColors.primaryPurple, AppColors.primaryLight],
                      ).createShader(const Rect.fromLTWH(0, 0, 200, 50)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'You completed this lesson!',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _markAsCompleted() async {
    try {
      await ref.read(lessonActionsProvider).markAsCompleted(widget.lesson.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Lesson completed! 🎹'),
              ],
            ),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.errorRed),
        );
      }
    }
  }

  void _resetPractice() {
    setState(() {
      _playedNotes.clear();
      _practiceCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final backgroundColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Hero(
                tag: 'lesson_title_${widget.lesson.id}',
                child: Text(
                  widget.lesson.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              backgroundColor: AppColors.primaryPurple,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.bookmark_border, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Introduction Card
                  GlassContainer(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    opacity: isDark ? 0.12 : 0.08,
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getDifficultyColor(),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.lesson.difficultyLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(Icons.access_time, size: 14, color: textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.lesson.estimatedDuration} min',
                              style: TextStyle(fontSize: 12, color: textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'What you\'ll learn:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...widget.lesson.objectives.map(
                          (objective) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 3),
                                  width: 18,
                                  height: 18,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryPurple,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check, color: Colors.white, size: 10),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    objective,
                                    style: TextStyle(color: textPrimary, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Theory Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: LessonTheorySection(
                      theoryText: widget.lesson.content.theoryText,
                      tips: widget.lesson.content.tips,
                      illustrationUrl: widget.lesson.content.illustrationUrl,
                    ),
                  ),
                  // Demo Section
                  if (widget.lesson.content.demoNotes.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: LessonDemoSection(
                        demoNotes: widget.lesson.content.demoNotes,
                      ),
                    ),
                  // Practice Section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(18),
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
                                  color: AppColors.successGreen.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.piano, color: AppColors.successGreen, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Your Turn! 🎹',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: textPrimary,
                                ),
                              ),
                              const Spacer(),
                              if (_playedNotes.isNotEmpty)
                                TextButton.icon(
                                  onPressed: _resetPractice,
                                  icon: const Icon(Icons.refresh, size: 16),
                                  label: const Text('Reset'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primaryPurple,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Play these notes in order:',
                            style: TextStyle(color: textSecondary, fontSize: 13),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: widget.lesson.content.practiceNotes
                                .asMap()
                                .entries
                                .map((entry) {
                                  final index = entry.key;
                                  final note = entry.value;
                                  final isPlayed = index < _playedNotes.length;
                                  final isCorrect = isPlayed && _playedNotes[index] == note;

                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isCorrect
                                          ? AppColors.successGreen
                                          : isPlayed
                                              ? AppColors.errorRed
                                              : null,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isCorrect
                                            ? AppColors.successGreen
                                            : isPlayed
                                                ? AppColors.errorRed
                                                : AppColors.successGreen.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      note,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isPlayed ? Colors.white : textPrimary,
                                      ),
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                          const SizedBox(height: 20),
                          // Piano keyboard
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : AppColors.surfaceVariantLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: PianoKeyboard(
                              numberOfOctaves: 1,
                              showLabels: true,
                              highlightedNotes: widget.lesson.notesToLearn
                                  .map((noteStr) => _getNoteFromString(noteStr))
                                  .whereType<Note>()
                                  .toList(),
                              onNotePlayed: _handleNotePlayed,
                              enableSound: true,
                              keyWidth: 40,
                              keyHeight: 120,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Bottom Actions
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _practiceCompleted ? _markAsCompleted : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _practiceCompleted
                                  ? AppColors.primaryPurple
                                  : AppColors.primaryPurple.withOpacity(0.4),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_practiceCompleted) const Icon(Icons.verified, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  _practiceCompleted ? 'Mark as Completed' : 'Complete Practice First',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!_practiceCompleted)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.info_outline, size: 14, color: textSecondary),
                                const SizedBox(width: 6),
                                Text(
                                  'Play all notes correctly to unlock',
                                  style: TextStyle(fontSize: 12, color: textSecondary),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Confetti
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor() {
    switch (widget.lesson.difficulty.toLowerCase()) {
      case 'beginner':
        return AppColors.successGreen;
      case 'intermediate':
        return AppColors.warningOrange;
      case 'advanced':
        return AppColors.errorRed;
      default:
        return AppColors.successGreen;
    }
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
}
