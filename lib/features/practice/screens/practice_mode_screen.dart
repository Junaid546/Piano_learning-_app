import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
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

class _PracticeModeScreenState extends ConsumerState<PracticeModeScreen>
    with TickerProviderStateMixin {
  String _difficulty = 'easy';
  late AnimationController _challengeController;
  late AnimationController _timerController;
  bool _showResult = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _challengeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _timerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _challengeController.dispose();
    _timerController.dispose();
    super.dispose();
  }

  void _onNotePlayed(Note note) {
    final provider = ref.read(practiceProvider(_difficulty).notifier);
    
    // Check if time is up for timed challenges
    if (provider.state.currentChallenge.timeLimit != null) {
      final timeRemaining = provider.state.currentChallenge.timeLimit! - 
          (provider.state.currentChallenge.timeLimit! * _timerController.value).round();
      if (timeRemaining <= 0) {
        _showTimeUpResult();
        return;
      }
    }
    
    provider.checkNote(note.fullName);
  }

  void _showTimeUpResult() {
    if (!_showResult) {
      setState(() {
        _showResult = true;
        _isSuccess = false;
      });
      _timerController.stop();
    }
  }

  void _showSuccessResult() {
    if (!_showResult) {
      setState(() {
        _showResult = true;
        _isSuccess = true;
      });
    }
  }

  void _changeDifficulty(String difficulty) {
    setState(() => _difficulty = difficulty);
    _showResult = false;
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
    final screenHeight = MediaQuery.of(context).size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate responsive keyboard height - 30% of screen, max 180, min 120
    final keyboardHeight = (screenHeight * 0.30).clamp(120.0, 180.0);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnimatedBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Top Bar with AppBar
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    } else {
                                      context.go('/');
                                    }
                                  },
                                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                ),
                                // Title with difficulty badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primaryPurple,
                                        AppColors.primaryPurple.withValues(alpha: 0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryPurple.withValues(alpha: 0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _difficulty == 'easy' ? Icons.music_note :
                                            _difficulty == 'medium' ? Icons.speed : Icons.bolt,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _difficulty.toUpperCase(),
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Sound toggle
                                Consumer(
                                  builder: (context, ref, child) {
                                    final isMuted = ref.watch(audioMutedProvider);
                                    return IconButton(
                                      icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
                                      onPressed: () {
                                        ref.read(audioMutedProvider.notifier).toggleMute();
                                      },
                                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Score Display
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: GlassContainer(
                              opacity: 0.15,
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: ScoreDisplay(
                                  score: state.session.score,
                                  streak: state.currentStreak,
                                  accuracy: state.session.accuracy,
                                  difficulty: _difficulty,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Challenge Card
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ChallengeCard(
                              challenge: state.currentChallenge,
                              difficulty: _difficulty,
                              onTimeUp: _showTimeUpResult,
                              onSuccess: _showSuccessResult,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Difficulty Selector
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildDifficultyButton('easy', 'Easy', Icons.music_note),
                                const SizedBox(width: 12),
                                _buildDifficultyButton('medium', 'Medium', Icons.speed),
                                const SizedBox(width: 12),
                                _buildDifficultyButton('hard', 'Hard', Icons.bolt),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  
                  // Piano Keyboard with responsive height
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark 
                            ? [Colors.grey.shade900, Colors.black]
                            : [Colors.grey.shade800, Colors.grey.shade900],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryPurple.withOpacity(0.2),
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
                    padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
                    child: Consumer(
                      builder: (context, ref, child) {
                        final isMuted = ref.watch(audioMutedProvider);
                        return SizedBox(
                          height: keyboardHeight,
                          child: PianoKeyboard(
                            numberOfOctaves: 1,
                            showLabels: true,
                            onNotePlayed: _onNotePlayed,
                            enableSound: !isMuted,
                            keyWidth: (MediaQuery.of(context).size.width - 80) / 7 - 2,
                            keyHeight: keyboardHeight.clamp(100.0, 160.0),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              
              // Feedback Overlay
              if (state.showFeedback)
                Positioned.fill(
                  child: Center(
                    child: FeedbackOverlay(feedbackType: state.feedbackType),
                  ),
                ),

              // Processing Overlay - prevents rapid interaction
              if (state.isProcessing)
                Positioned.fill(
                  child: AbsorbPointer(
                    child: Container(
                      color: Colors.transparent,
                    ),
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
                                color: isDark ? Colors.white : AppColors.textPrimaryLight,
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
                                  color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              
              // Result Overlay with Lottie
              if (_showResult)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.7),
                    child: Center(
                      child: SingleChildScrollView(
                        child: GlassContainer(
                          padding: const EdgeInsets.all(24),
                          borderRadius: BorderRadius.circular(28),
                          opacity: 0.95,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Lottie animation
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: _isSuccess 
                                    ? Lottie.asset('assets/lottie/Success.json')
                                    : Lottie.asset('assets/lottie/Loading_animation.json'),
                              ),
                              const SizedBox(height: 16),
                              // Result text
                              Text(
                                _isSuccess ? '🎉 You Win!' : '⏰ Time\'s Up!',
                                style: AppTextStyles.titleLarge.copyWith(
                                  color: _isSuccess ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isSuccess 
                                    ? 'Great job! You completed the challenge!'
                                    : 'Don\'t give up! Try again!',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              // Action buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _endSession,
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        side: const BorderSide(color: AppColors.primaryPurple),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        'End Session',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: AppColors.primaryPurple,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() => _showResult = false);
                                        _changeDifficulty(_difficulty);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryPurple,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 4,
                                      ),
                                      child: Text(
                                        'Try Again',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(String difficulty, String label, IconData icon) {
    final isSelected = _difficulty == difficulty;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedPressScale(
      onPressed: () => _changeDifficulty(difficulty),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryPurple
              : isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : isDark
                      ? Colors.white70
                      : AppColors.textPrimaryLight,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected
                    ? Colors.white
                    : isDark
                        ? Colors.white70
                        : AppColors.textPrimaryLight,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
