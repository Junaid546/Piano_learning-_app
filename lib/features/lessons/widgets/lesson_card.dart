import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final textTertiary = isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      opacity: lesson.isLocked ? 0.03 : 0.08,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: lesson.isCompleted
            ? AppColors.successGreen.withOpacity(0.4)
            : lesson.isLocked
                ? Colors.grey.withOpacity(0.15)
                : AppColors.primaryPurple.withOpacity(0.15),
        width: 1,
      ),
      gradient: lesson.isLocked
          ? null
          : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [AppColors.surfaceDark.withOpacity(0.9), AppColors.surfaceVariantDark.withOpacity(0.7)]
                  : [AppColors.surfaceLight.withOpacity(0.95), AppColors.surfaceLight.withOpacity(0.8)],
            ),
      boxShadow: lesson.isLocked
          ? []
          : [
              BoxShadow(
                color: AppColors.primaryPurple.withOpacity(isDark ? 0.1 : 0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: lesson.isLocked ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              // Lesson number badge
              Container(
                width: 44,
                height: 44,
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: lesson.isLocked
                      ? null
                      : const LinearGradient(
                          colors: [AppColors.primaryPurple, AppColors.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  color: lesson.isLocked
                      ? (isDark ? Colors.grey.shade800 : Colors.grey.shade300)
                      : null,
                  shape: BoxShape.circle,
                  boxShadow: lesson.isLocked
                      ? []
                      : [
                          BoxShadow(
                            color: AppColors.primaryPurple.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Center(
                  child: lesson.isLocked
                      ? Icon(
                          Icons.lock,
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                          size: 18,
                        )
                      : Text(
                          '${lesson.order}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              // Lesson info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: 'lesson_title_${lesson.id}',
                        child: Text(
                          lesson.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: lesson.isLocked ? textTertiary : textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lesson.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: lesson.isLocked ? textTertiary.withOpacity(0.6) : textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${lesson.estimatedDuration} min',
                            style: TextStyle(
                              fontSize: 11,
                              color: textTertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor().withOpacity(isDark ? 0.15 : 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: _getDifficultyColor(),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  lesson.difficultyLabel,
                                  style: TextStyle(
                                    fontSize: 10,
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
              ),
              // Chevron or completed badge
              if (!lesson.isLocked)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: lesson.isCompleted
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.successGreen,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check, color: Colors.white, size: 12),
                              SizedBox(width: 2),
                              Text(
                                'DONE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.primaryPurple.withOpacity(0.5),
                          size: 22,
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
