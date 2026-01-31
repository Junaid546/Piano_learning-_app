import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/loading_indicator.dart';
import '../auth/providers/auth_provider.dart';
import 'providers/home_provider.dart';
import 'widgets/action_card.dart';
import 'widgets/progress_overview_card.dart';
import 'widgets/quick_stats_row.dart';
import 'widgets/welcome_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).userModel;
    final progressAsync = ref.watch(homeProvider);

    return SafeArea(
      bottom: false,
      child: progressAsync.when(
        data: (progress) => RefreshIndicator(
          onRefresh: () async {
            // Refetch data logic would go here
            // Current stream provider updates automatically, but we can fake a delay
            await Future.delayed(const Duration(seconds: 1));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header
                WelcomeHeader(
                  userName: user?.displayName ?? 'Pianist',
                  profileImageUrl: user?.profileImageUrl,
                  onProfileTap: () {
                    // Navigate to profile
                  },
                ),
                const SizedBox(height: 32),

                // 2. Progress Overview
                ProgressOverviewCard(progress: progress),
                const SizedBox(height: 24),

                // 3. Quick Stats
                QuickStatsRow(
                  lessonsCompleted: progress.lessonsCompletedCount,
                  level: progress.currentLevel,
                  achievements: progress.recentAchievements.length,
                ),
                const SizedBox(height: 32),

                // 4. Action Section
                Text(
                  'Start Learning',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ActionCard(
                  title: 'Resume Course',
                  subtitle: 'Continue where you left off',
                  icon: Icons.play_circle_fill_rounded,
                  color: AppColors.primaryPurple,
                  onTap: () {
                    context.go('/lessons');
                  },
                ),
                const SizedBox(height: 16),
                ActionCard(
                  title: 'Practice Mode',
                  subtitle: 'Free play with instant feedback',
                  icon: Icons.piano,
                  color: AppColors.secondaryPink,
                  onTap: () {
                    context.go('/practice');
                  },
                ),
                const SizedBox(height: 100), // Bottom padding for nav bar
              ],
            ),
          ),
        ),
        loading: () => const Center(
          child: LoadingIndicator(type: LoadingIndicatorType.spinner),
        ),
        error: (error, stack) =>
            Center(child: Text('Error loading dashboard: $error')),
      ),
    );
  }
}
