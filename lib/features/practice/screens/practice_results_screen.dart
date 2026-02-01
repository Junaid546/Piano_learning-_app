import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/practice_session.dart';
import 'practice_mode_screen.dart';

class PracticeResultsScreen extends StatefulWidget {
  final PracticeSession session;

  const PracticeResultsScreen({super.key, required this.session});

  @override
  State<PracticeResultsScreen> createState() => _PracticeResultsScreenState();
}

class _PracticeResultsScreenState extends State<PracticeResultsScreen>
    with TickerProviderStateMixin {
  late AnimationController _scoreController;
  late Animation<int> _scoreAnimation;
  late AnimationController _starsController;

  @override
  void initState() {
    super.initState();
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scoreAnimation = IntTween(
      begin: 0,
      end: widget.session.score,
    ).animate(CurvedAnimation(parent: _scoreController, curve: Curves.easeOut));

    _starsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      _scoreController.forward();
      _starsController.forward();
    });
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _starsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              // Trophy Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber, Colors.orange.shade700],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Practice Complete!',
                style: AppTextStyles.displaySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Great job! Keep practicing to improve.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 32),
              // Stars
              ScaleTransition(
                scale: _starsController,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final earned = index < widget.session.stars;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        earned ? Icons.star : Icons.star_border,
                        size: 48,
                        color: earned ? Colors.amber : Colors.grey.shade400,
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 32),
              // Score
              AnimatedBuilder(
                animation: _scoreAnimation,
                builder: (context, child) {
                  return Text(
                    '${_scoreAnimation.value}',
                    style: AppTextStyles.displayLarge.copyWith(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryPurple,
                    ),
                  );
                },
              ),
              Text(
                'Total Score',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 32),
              // Stats Grid
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            Icons.check_circle,
                            Colors.green,
                            '${widget.session.correctAttempts}/${widget.session.totalAttempts}',
                            'Correct',
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            Icons.percent,
                            Colors.blue,
                            '${widget.session.accuracy.toStringAsFixed(0)}%',
                            'Accuracy',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            Icons.timer,
                            Colors.orange,
                            widget.session.formattedDuration,
                            'Duration',
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            Icons.local_fire_department,
                            Colors.red,
                            '${widget.session.longestStreak}',
                            'Best Streak',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text(
                            '+${widget.session.xpEarned} XP Earned',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.primaryPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PracticeModeScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Practice Again',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: AppColors.primaryPurple),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    Color color,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryLight,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
