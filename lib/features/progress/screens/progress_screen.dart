import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../providers/progress_provider.dart';
import '../widgets/stats_overview.dart';
import '../widgets/progress_chart.dart';
import '../widgets/achievement_grid.dart';
import '../models/achievement.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(userProgressProvider);
    final achievementsAsync = ref.watch(achievementsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Your Progress'),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: progressAsync.when(
        data: (progress) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Overview
                StatsOverview(
                  lessonsCompleted: progress.lessonsCompleted,
                  totalLessons: progress.totalLessons,
                  practiceHours: progress.totalPracticeHours,
                  currentStreak: progress.currentStreak,
                  accuracy: progress.accuracy,
                ),
                const SizedBox(height: 24),

                // Progress Chart
                if (progress.practiceDates.isNotEmpty) ...[
                  ProgressChart(practiceDates: progress.practiceDates),
                  const SizedBox(height: 24),
                ],

                // Level & XP
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Level ${progress.level}',
                            style: AppTextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${progress.xp} / ${progress.xpToNextLevel} XP',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress.levelProgress,
                          minHeight: 12,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primaryPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Achievements Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Achievements',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    achievementsAsync.when(
                      data: (achievements) {
                        final unlocked = achievements
                            .where((a) => a.isUnlocked)
                            .length;
                        return Text(
                          '$unlocked/${achievements.length}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        );
                      },
                      loading: () => const SizedBox(),
                      error: (_, __) => const SizedBox(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                achievementsAsync.when(
                  data: (achievements) {
                    return AchievementGrid(
                      achievements: achievements,
                      onTap: (achievement) {
                        _showAchievementDetail(context, achievement);
                      },
                    );
                  },
                  loading: () => const Center(child: LoadingIndicator()),
                  error: (error, stack) =>
                      Center(child: Text('Error loading achievements: $error')),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error loading progress: $error')),
      ),
    );
  }

  void _showAchievementDetail(BuildContext context, Achievement achievement) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final color = _getRarityColor(achievement.rarity);
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconData(achievement.iconName),
                  size: 48,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                achievement.title,
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  achievement.rarity.toUpperCase(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                achievement.description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (!achievement.isUnlocked) ...[
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${achievement.currentProgress}/${achievement.requirement}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: achievement.progressPercentage / 100,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'Unlocked!',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'bronze':
        return Colors.brown;
      case 'silver':
        return Colors.grey.shade600;
      case 'gold':
        return Colors.amber;
      case 'platinum':
        return AppColors.primaryPurple;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'school': Icons.school,
      'menu_book': Icons.menu_book,
      'auto_stories': Icons.auto_stories,
      'workspace_premium': Icons.workspace_premium,
      'fitness_center': Icons.fitness_center,
      'sports_gymnastics': Icons.sports_gymnastics,
      'emoji_events': Icons.emoji_events,
      'military_tech': Icons.military_tech,
      'calendar_today': Icons.calendar_today,
      'event_repeat': Icons.event_repeat,
      'event_available': Icons.event_available,
      'date_range': Icons.date_range,
      'celebration': Icons.celebration,
      'gps_fixed': Icons.gps_fixed,
      'my_location': Icons.my_location,
      'stars': Icons.stars,
      'music_note': Icons.music_note,
      'library_music': Icons.library_music,
      'queue_music': Icons.queue_music,
      'piano': Icons.piano,
      'access_time': Icons.access_time,
      'schedule': Icons.schedule,
      'timer': Icons.timer,
      'hourglass_full': Icons.hourglass_full,
    };
    return iconMap[iconName] ?? Icons.emoji_events;
  }
}
