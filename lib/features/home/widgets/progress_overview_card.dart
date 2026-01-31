import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/progress_ring.dart';
import '../models/progress_summary.dart';

class ProgressOverviewCard extends StatelessWidget {
  final ProgressSummary progress;

  const ProgressOverviewCard({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryPurple,
            Color(0xFF8E70FF),
          ], // Custom gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Progress Ring
          SizedBox(
            width: 80,
            height: 80,
            child: ProgressRing(
              progress: progress.totalProgress,
              strokeWidth: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              progressColor: Colors.white,
              centerContent: Center(
                child: Text(
                  '${(progress.totalProgress * 100).toInt()}%',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Progress',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(
                      label: 'Lessons',
                      value:
                          '${progress.lessonsCompletedCount}/${progress.totalLessons}',
                    ),
                    _buildStatItem(
                      label: 'Time',
                      value:
                          '${(progress.totalPracticeTimeMinutes / 60).toStringAsFixed(1)}h',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
