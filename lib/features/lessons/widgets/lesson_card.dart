import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/lesson.dart';

class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback onTap;

  const LessonCard({super.key, required this.lesson, required this.onTap});

  Color _getDifficultyColor() {
    switch (lesson.difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  IconData _getStatusIcon() {
    if (lesson.isCompleted) return Icons.check_circle;
    if (lesson.isLocked) return Icons.lock;
    return Icons.play_circle_outline;
  }

  Color _getStatusColor() {
    if (lesson.isCompleted) return Colors.green;
    if (lesson.isLocked) return Colors.grey;
    return AppColors.primaryPurple;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: lesson.isLocked ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: lesson.isLocked
              ? LinearGradient(
                  colors: [Colors.grey.shade300, Colors.grey.shade200],
                )
              : LinearGradient(
                  colors: [
                    AppColors.primaryPurple.withValues(alpha: 0.1),
                    AppColors.infoBlue.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: lesson.isCompleted
                ? Colors.green.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Lesson number badge
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: lesson.isLocked
                          ? const Icon(
                              Icons.lock,
                              color: Colors.white,
                              size: 24,
                            )
                          : Text(
                              '${lesson.order}',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Lesson info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.title,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: lesson.isLocked
                                ? Colors.grey.shade600
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lesson.description,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: lesson.isLocked
                                ? Colors.grey.shade500
                                : AppColors.textSecondaryLight,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Duration
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${lesson.estimatedDuration} min',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Difficulty
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _getDifficultyColor(),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              lesson.difficultyLabel,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Status icon
                  Icon(_getStatusIcon(), color: _getStatusColor(), size: 32),
                ],
              ),
            ),
            // Status badge
            if (lesson.isCompleted || !lesson.isLocked)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: lesson.isCompleted
                        ? Colors.green
                        : AppColors.primaryPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    lesson.statusLabel,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
