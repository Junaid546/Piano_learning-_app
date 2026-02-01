import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../piano/widgets/piano_keyboard.dart';
import '../../piano/models/note.dart';
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
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
        title: const Text('Practice Mode'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _showExitDialog,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Settings
            },
          ),
        ],
      ),
      body: Stack(
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 32),
                child: PianoKeyboard(
                  numberOfOctaves: 1,
                  showLabels: true,
                  onNotePlayed: _onNotePlayed,
                  enableSound: true,
                  keyWidth: 50,
                  keyHeight: 180,
                ),
              ),
            ],
          ),
          // Feedback Overlay
          if (state.showFeedback)
            Positioned.fill(
              child: Center(child: FeedbackOverlay(isCorrect: state.isCorrect)),
            ),
          // Pause Overlay
          if (state.isPaused)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Paused', style: AppTextStyles.displaySmall),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .read(practiceProvider(_difficulty).notifier)
                                .togglePause();
                          },
                          child: const Text('Resume'),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _endSession,
                          child: const Text('End Practice'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDifficultyButton(String difficulty, String label) {
    final isSelected = _difficulty == difficulty;
    return GestureDetector(
      onTap: () => _changeDifficulty(difficulty),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPurple : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimaryLight,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
