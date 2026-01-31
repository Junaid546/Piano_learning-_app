import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/achievement.dart';

class AchievementGrid extends StatelessWidget {
  final List<Achievement> achievements;
  final Function(Achievement) onTap;

  const AchievementGrid({
    super.key,
    required this.achievements,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _buildAchievementBadge(achievement);
      },
    );
  }

  Widget _buildAchievementBadge(Achievement achievement) {
    final isLocked = !achievement.isUnlocked;
    final color = _getRarityColor(achievement.rarity);

    return GestureDetector(
      onTap: () => onTap(achievement),
      child: Container(
        decoration: BoxDecoration(
          color: isLocked ? Colors.grey.shade200 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLocked ? Colors.grey.shade300 : color,
            width: 2,
          ),
          boxShadow: isLocked
              ? []
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconData(achievement.iconName),
              size: 40,
              color: isLocked ? Colors.grey.shade400 : color,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                achievement.title,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isLocked
                      ? Colors.grey.shade500
                      : AppColors.textPrimaryLight,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (achievement.isInProgress && !isLocked) ...[
              const SizedBox(height: 4),
              SizedBox(
                width: 50,
                child: LinearProgressIndicator(
                  value: achievement.progressPercentage / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ],
        ),
      ),
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
