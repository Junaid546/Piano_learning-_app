import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/animations.dart';
import '../../../core/widgets/glass_container.dart';
import '../models/lesson.dart';

class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback onTap;

  const LessonCard({super.key, required this.lesson, required this.onTap});

  Color _getDifficultyColor() {
    switch (lesson.difficulty.toLowerCase()) {
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

  @override
  Widget build(BuildContext context) {
    return AnimatedPressScale(
      onPressed: lesson.isLocked ? null : onTap,
      child: GlassContainer(
        margin: const EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.zero,
        opacity: lesson.isLocked ? 0.05 : 0.1,
        border: Border.all(
          color: lesson.isCompleted
              ? AppColors.successGreen.withOpacity(0.5)
              : lesson.isLocked
              ? Colors.grey.withOpacity(0.2)
              : AppColors.primaryPurple.withOpacity(0.2),
          width: 1.5,
        ),
        gradient: lesson.isLocked
            ? LinearGradient(
                colors: [
                  Colors.grey.withOpacity(0.1),
                  Colors.grey.withOpacity(0.05),
                ],
              )
            : LinearGradient(
                colors: [
                  AppColors.surfaceLight.withOpacity(0.8),
                  AppColors.surfaceLight.withOpacity(0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
                      gradient: lesson.isLocked
                          ? null
                          : AppColors.primaryGradient,
                      color: lesson.isLocked
                          ? Colors.grey.withOpacity(0.3)
                          : null,
                      shape: BoxShape.circle,
                      boxShadow: lesson.isLocked
                          ? []
                          : [
                              BoxShadow(
                                color: AppColors.primaryPurple.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Center(
                      child: lesson.isLocked
                          ? const Icon(
                              Icons.lock,
                              color: Colors.white70,
                              size: 20,
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
                        Hero(
                          tag: 'lesson_title_${lesson.id}',
                          child: Text(
                            lesson.title,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: lesson.isLocked
                                  ? AppColors.textTertiaryLight
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lesson.description,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: lesson.isLocked
                                ? AppColors.textTertiaryLight
                                : AppColors.textSecondaryLight,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            // Duration
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${lesson.estimatedDuration} min',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Difficulty
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getDifficultyColor().withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: _getDifficultyColor(),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    lesson.difficultyLabel,
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: _getDifficultyColor(),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Chevron
                  if (!lesson.isLocked)
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.primaryPurple.withOpacity(0.5),
                      size: 24,
                    ),
                ],
              ),
            ),
            // Status badge
            if (lesson.isCompleted)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'COMPLETED',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
