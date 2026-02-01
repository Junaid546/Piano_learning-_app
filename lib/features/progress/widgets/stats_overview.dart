import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class StatsOverview extends StatelessWidget {
  final int lessonsCompleted;
  final int totalLessons;
  final int practiceHours;
  final int currentStreak;
  final double accuracy;

  const StatsOverview({
    super.key,
    required this.lessonsCompleted,
    required this.totalLessons,
    required this.practiceHours,
    required this.currentStreak,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          icon: Icons.school,
          title: 'Lessons',
          value: lessonsCompleted,
          suffix: '/$totalLessons',
          gradient: [
            AppColors.primaryPurple,
            AppColors.primaryPurple.withValues(alpha: 0.7),
          ],
        ),
        _buildStatCard(
          icon: Icons.access_time,
          title: 'Practice Time',
          value: practiceHours,
          suffix: 'h',
          gradient: [
            AppColors.infoBlue,
            AppColors.infoBlue.withValues(alpha: 0.7),
          ],
        ),
        _buildStatCard(
          icon: Icons.local_fire_department,
          title: 'Streak',
          value: currentStreak,
          suffix: ' days',
          gradient: [Colors.orange, Colors.orange.shade700],
        ),
        _buildStatCard(
          icon: Icons.gps_fixed,
          title: 'Accuracy',
          value: accuracy,
          suffix: '%',
          gradient: [Colors.green, Colors.green.shade700],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required num value,
    String? suffix,
    String? prefix,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          TweenAnimationBuilder<num>(
            tween: Tween<num>(begin: 0, end: value),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutQuart,
            builder: (context, val, child) {
              return Text(
                '${prefix ?? ''}${val is int ? val : val.toStringAsFixed(0)}${suffix ?? ''}',
                style: AppTextStyles.displaySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
