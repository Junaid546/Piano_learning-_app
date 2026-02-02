import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// Reusable empty state widget
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: iconColor ?? AppColors.textTertiary),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[const SizedBox(height: 32), action!],
          ],
        ),
      ),
    );
  }
}

/// Empty state for no lessons
class NoLessonsEmptyState extends StatelessWidget {
  final VoidCallback? onRefresh;

  const NoLessonsEmptyState({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.library_music_outlined,
      title: 'No Lessons Available',
      message:
          'Lessons will appear here once they\'re published. Check back soon!',
      iconColor: AppColors.primaryPurple,
      action: onRefresh != null
          ? ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: Colors.white,
              ),
            )
          : null,
    );
  }
}

/// Empty state for no practice history
class NoPracticeEmptyState extends StatelessWidget {
  final VoidCallback? onStartPractice;

  const NoPracticeEmptyState({super.key, this.onStartPractice});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.piano_outlined,
      title: 'No Practice History',
      message:
          'Start practicing to track your progress and see your improvement over time!',
      iconColor: AppColors.infoBlue,
      action: onStartPractice != null
          ? ElevatedButton.icon(
              onPressed: onStartPractice,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Practicing'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: Colors.white,
              ),
            )
          : null,
    );
  }
}

/// Empty state for no achievements
class NoAchievementsEmptyState extends StatelessWidget {
  const NoAchievementsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.emoji_events_outlined,
      title: 'No Achievements Yet',
      message:
          'Complete lessons and practice regularly to unlock achievements and badges!',
      iconColor: Colors.amber,
    );
  }
}

/// Error state widget
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorStateWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Oops! Something went wrong',
      message: message,
      iconColor: AppColors.errorRed,
      action: onRetry != null
          ? ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: Colors.white,
              ),
            )
          : null,
    );
  }
}
