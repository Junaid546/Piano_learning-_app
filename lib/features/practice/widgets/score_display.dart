import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class ScoreDisplay extends StatelessWidget {
  final int score;
  final int streak;
  final double accuracy;
  final String difficulty;

  const ScoreDisplay({
    super.key,
    required this.score,
    required this.streak,
    required this.accuracy,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Score
          _buildStat(
            icon: Icons.stars_rounded,
            iconColor: Colors.amber,
            label: 'Score',
            value: score.toString(),
            valueKey: ValueKey('score_$score'), // Trigger animation on change
          ),
          _buildDivider(),
          // Streak
          _buildStat(
            icon: Icons.local_fire_department,
            iconColor: streak > 0 ? Colors.orange : Colors.grey,
            label: 'Streak',
            value: streak.toString(),
            suffix: streak > 0 ? ' 🔥' : '',
            isStreak: true,
          ),
          _buildDivider(),
          // Accuracy
          _buildStat(
            icon: Icons.gps_fixed,
            iconColor: _getAccuracyColor(),
            label: 'Accuracy',
            value: '${accuracy.toStringAsFixed(0)}%',
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    String suffix = '',
    Key? valueKey,
    bool isStreak = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 24)
            .animate(
              target:
                  isStreak &&
                      int.tryParse(value) != null &&
                      int.parse(value) > 5
                  ? 1
                  : 0,
            )
            .shimmer(color: Colors.orange, duration: 1200.ms),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                  value,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                )
                .animate(key: valueKey)
                .scale(
                  duration: 200.ms,
                  curve: Curves.easeOutBack,
                ), // Bump on update
            if (suffix.isNotEmpty)
              Text(
                    suffix,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.3, 1.3),
                    duration: 800.ms,
                  ),
          ],
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

  Widget _buildDivider() {
    return Container(width: 1, height: 40, color: Colors.grey.shade200);
  }

  Color _getAccuracyColor() {
    if (accuracy >= 80) return Colors.green;
    if (accuracy >= 60) return Colors.orange;
    return Colors.red;
  }
}
