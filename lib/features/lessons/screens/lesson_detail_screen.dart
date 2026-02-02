import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/animated_background.dart';
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
      duration: const Duration(seconds: 3),
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

      // Check if practice is completed
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Lottie.asset(
              'assets/lottie/Success.json',
              height: 60,
              repeat: false,
            ),
            const SizedBox(width: 12),
            const Text(
              'Great Job!',
            ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You\'ve completed the practice section!',
              style: AppTextStyles.bodyMedium,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 16),
            Text(
              '🎹 Keep practicing to master this lesson!',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue'),
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }

  Future<void> _markAsCompleted() async {
    try {
      await ref.read(lessonActionsProvider).markAsCompleted(widget.lesson.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lesson marked as completed!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
    return Scaffold(
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
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
        ],
      ),
      body: AnimatedBackground(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Introduction Card
                  GlassContainer(
                    borderRadius: BorderRadius.zero,
                    color: AppColors.surfaceLight.withOpacity(0.5),
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getDifficultyColor(),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.lesson.difficultyLabel,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: AppColors.textSecondaryLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.lesson.estimatedDuration} min',
                              style: AppTextStyles.bodySmall.copyWith(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white70
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'What you\'ll learn:',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...widget.lesson.objectives.map(
                          (objective) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primaryPurple,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    objective,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
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
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.piano,
                                color: AppColors.primaryPurple,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Your Turn!',
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                              const Spacer(),
                              if (_playedNotes.isNotEmpty)
                                TextButton.icon(
                                  onPressed: _resetPractice,
                                  icon: const Icon(Icons.refresh, size: 16),
                                  label: const Text('Reset'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Play these notes:',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: widget.lesson.content.practiceNotes
                                .asMap()
                                .entries
                                .map((entry) {
                                  final index = entry.key;
                                  final note = entry.value;
                                  final isPlayed = index < _playedNotes.length;
                                  final isCorrect =
                                      isPlayed && _playedNotes[index] == note;

                                  return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isCorrect
                                              ? AppColors.successGreen
                                              : isPlayed
                                              ? AppColors.errorRed
                                              : Colors.grey.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.withOpacity(0.2),
                                          ),
                                        ),
                                        child: Text(
                                          note,
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: isPlayed
                                                ? Colors.white
                                                : (Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                      : AppColors
                                                            .textPrimaryLight),
                                          ),
                                        ),
                                      )
                                      .animate(target: isCorrect ? 1 : 0)
                                      .scale(
                                        begin: const Offset(1, 1),
                                        end: const Offset(1.1, 1.1),
                                        duration: 200.ms,
                                        curve: Curves.easeOutBack,
                                      );
                                })
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                          PianoKeyboard(
                            numberOfOctaves: 1,
                            showLabels: true,
                            highlightedNotes: widget.lesson.notesToLearn
                                .map((noteStr) => _getNoteFromString(noteStr))
                                .whereType<Note>()
                                .toList(),
                            onNotePlayed: _handleNotePlayed,
                            enableSound: true,
                            keyWidth: 45,
                            keyHeight: 150,
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
                          child:
                              ElevatedButton(
                                    onPressed: _practiceCompleted
                                        ? _markAsCompleted
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryPurple,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      disabledBackgroundColor:
                                          Colors.grey.shade300,
                                    ),
                                    child: const Text(
                                      'Mark as Completed',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                  .animate(
                                    target: _practiceCompleted ? 1 : 0,
                                    onPlay: (c) => c.repeat(reverse: true),
                                  )
                                  .scaleXY(
                                    end: 1.05,
                                    duration: 1.seconds,
                                    curve: Curves.easeInOut,
                                  ),
                        ),
                        if (!_practiceCompleted)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Complete the practice to mark this lesson as done',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondaryLight,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
    };
    return noteMap[noteStr];
  }
}
