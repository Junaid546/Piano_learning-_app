import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/animations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/premium_button.dart';
import '../../../core/widgets/animated_background.dart';
import '../../piano/widgets/piano_keyboard.dart';
import '../../piano/models/note.dart';
import '../../piano/providers/audio_service_provider.dart';
import '../providers/practice_provider.dart';
import '../widgets/challenge_card.dart';
import '../widgets/score_display.dart';
import '../widgets/feedback_overlay.dart';
import 'practice_results_screen.dart';

class PracticeModeScreen extends ConsumerStatefulWidget {
  const PracticeModeScreen({super.key});

  @override
  ConsumerState<PracticeModeScreen> createState() => _PracticeModeScreenState();
}

class _PracticeModeScreenState extends ConsumerState<PracticeModeScreen> {
  String _difficulty = 'easy';

  void _onNotePlayed(Note note) {
    ref.read(practiceProvider(_difficulty).notifier).checkNote(note.fullName);
  }

  void _changeDifficulty(String difficulty) {
    setState(() => _difficulty = difficulty);
    ref
        .read(practiceProvider(_difficulty).notifier)
        .changeDifficulty(difficulty);
  }

  Future<void> _endSession() async {
    final session = await ref
        .read(practiceProvider(_difficulty).notifier)
        .endSession();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PracticeResultsScreen(session: session),
        ),
      );
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('End Practice?'),
        content: const Text('Your progress will be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _endSession();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
            ),
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(practiceProvider(_difficulty));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
        title: const Text('Practice Mode'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _showExitDialog,
        ),
        actions: [
          // Sound toggle button
          Consumer(
            builder: (context, ref, child) {
              final isMuted = ref.watch(audioMutedProvider);
              return IconButton(
                icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
                onPressed: () {
                  ref.read(audioMutedProvider.notifier).toggleMute();
                },
                tooltip: isMuted ? 'Unmute' : 'Mute',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Settings
            },
          ),
        ],
      ),
      body: AnimatedBackground(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 16),
                // Score Display
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ScoreDisplay(
                    score: state.session.score,
                    streak: state.currentStreak,
                    accuracy: state.session.accuracy,
                    difficulty: _difficulty,
                  ),
                ),
                const SizedBox(height: 24),
                // Challenge Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ChallengeCard(challenge: state.currentChallenge),
                ),
                const Spacer(),
                // Difficulty Selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDifficultyButton('easy', 'Easy'),
                      const SizedBox(width: 8),
                      _buildDifficultyButton('medium', 'Medium'),
                      const SizedBox(width: 8),
                      _buildDifficultyButton('hard', 'Hard'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Piano Keyboard
                Consumer(
                  builder: (context, ref, child) {
                    final isMuted = ref.watch(audioMutedProvider);
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.grey.shade900, Colors.black],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryPurple.withOpacity(0.3),
                            blurRadius: 30,
                            offset: const Offset(0, -10),
                          ),
                        ],
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(8, 24, 8, 100),
                      child: PianoKeyboard(
                        numberOfOctaves: 1,
                        showLabels: true,
                        onNotePlayed: _onNotePlayed,
                        enableSound: !isMuted,
                        keyWidth: 50,
                        keyHeight: 180,
                      ),
                    );
                  },
                ),
              ],
            ),
            // Feedback Overlay
            if (state.showFeedback)
              Positioned.fill(
                child: Center(
                  child: FeedbackOverlay(isCorrect: state.isCorrect),
                ),
              ),
            // Pause Overlay
            if (state.isPaused)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: GlassContainer(
                      padding: const EdgeInsets.all(32),
                      borderRadius: BorderRadius.circular(24),
                      opacity: 0.9,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Paused',
                            style: AppTextStyles.displaySmall.copyWith(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 24),
                          PremiumButton(
                            label: 'Resume',
                            onPressed: () {
                              ref
                                  .read(practiceProvider(_difficulty).notifier)
                                  .togglePause();
                            },
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _endSession,
                            child: Text(
                              'End Practice',
                              style: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white70
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(String difficulty, String label) {
    final isSelected = _difficulty == difficulty;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedPressScale(
      onPressed: () => _changeDifficulty(difficulty),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryPurple
              : isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withOpacity(0.2),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryPurple.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected
                ? Colors.white
                : isDark
                ? Colors.white70
                : AppColors.textPrimaryLight,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
