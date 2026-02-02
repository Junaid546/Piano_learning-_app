import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/practice_challenge.dart';

class ChallengeCard extends StatefulWidget {
  final PracticeChallenge challenge;
  final String difficulty;
  final VoidCallback? onTimeUp;
  final VoidCallback? onSuccess;
  final VoidCallback? onAnimationComplete;

  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.difficulty,
    this.onTimeUp,
    this.onSuccess,
    this.onAnimationComplete,
  });

  @override
  State<ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends State<ChallengeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _timeRemaining = 0;
  bool _isCountingDown = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
    
    // Start countdown if there's a time limit
    if (widget.challenge.timeLimit != null) {
      _startCountdown();
    }
  }

  @override
  void didUpdateWidget(covariant ChallengeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.challenge.id != widget.challenge.id) {
      _controller.reset();
      _controller.forward();
      
      // Reset countdown for new challenge
      if (widget.challenge.timeLimit != null) {
        _startCountdown();
      }
    }
  }

  void _startCountdown() {
    if (widget.challenge.timeLimit == null) return;
    
    _timeRemaining = widget.challenge.timeLimit!;
    _isCountingDown = true;
    
    // Use a separate controller for the countdown
    Future.delayed(Duration.zero, () {
      if (mounted) {
        _startTimerAnimation();
      }
    });
  }

  void _startTimerAnimation() {
    if (!mounted || _timeRemaining <= 0) return;
    
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      
      setState(() {
        _timeRemaining--;
      });
      
      if (_timeRemaining <= 0) {
        _isCountingDown = false;
        widget.onTimeUp?.call();
      } else {
        _startTimerAnimation();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Determine timer color based on time remaining
    Color timerColor = Colors.white;
    if (_timeRemaining <= 3 && _timeRemaining > 0) {
      timerColor = Colors.red;
    } else if (_timeRemaining <= 5) {
      timerColor = Colors.orange;
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getDifficultyColor().withValues(alpha: 0.9),
              _getDifficultyColor().withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _getDifficultyColor().withValues(alpha: 0.4),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Difficulty indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getDifficultyIcon(),
                    color: Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.difficulty.toUpperCase()} CHALLENGE',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Instruction text
              Text(
                widget.challenge.isSequence ? 'Play this sequence' : 'Play this note',
                style: AppTextStyles.titleMedium.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              
              // Note display circle
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(
                    color: _getDifficultyColor().withValues(alpha: 0.3),
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.challenge.targetNote,
                    style: AppTextStyles.displayMedium.copyWith(
                      color: _getDifficultyColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Timer display (for timed challenges)
              if (widget.challenge.timeLimit != null)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _timeRemaining <= 3 
                        ? Colors.red.withValues(alpha: 0.3)
                        : _timeRemaining <= 5 
                            ? Colors.orange.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: timerColor.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer,
                        color: timerColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$_timeRemaining',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: timerColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ).animate(
                        target: _timeRemaining <= 3 ? 1 : 0,
                      ).shimmer(
                        color: Colors.red,
                        duration: 600.ms,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'sec',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: timerColor,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time, color: Colors.white70, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'No time limit',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor() {
    switch (widget.difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return AppColors.primaryPurple;
    }
  }

  IconData _getDifficultyIcon() {
    switch (widget.difficulty) {
      case 'easy':
        return Icons.eco;
      case 'medium':
        return Icons.speed;
      case 'hard':
        return Icons.bolt;
      default:
        return Icons.music_note;
    }
  }
}
