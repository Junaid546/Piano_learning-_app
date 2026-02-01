import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/utils/animations.dart';
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

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? AppColors.surfaceGradientDark
              : AppColors.surfaceGradientLight,
        ),
        child: SafeArea(
          bottom: false,
          child: progressAsync.when(
            data: (progress) => RefreshIndicator(
              onRefresh: () async {
                // Refetch data logic would go here
                await Future.delayed(const Duration(seconds: 1));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Header
                    WelcomeHeader(
                      userName: user?.displayName ?? 'Pianist',
                      profileImageUrl: user?.profileImageUrl,
                      onProfileTap: () {
                        context.push('/profile');
                      },
                    ).slideUpFade(delay: AppAnimations.staggerLow),
                    const SizedBox(height: 32),

                    // 2. Progress Overview
                    ProgressOverviewCard(
                      progress: progress,
                    ).slideUpFade(delay: AppAnimations.staggerMedium),
                    const SizedBox(height: 24),

                    // 3. Quick Stats
                    QuickStatsRow(
                      lessonsCompleted: progress.lessonsCompletedCount,
                      level: progress.currentLevel,
                      achievements: progress.recentAchievements.length,
                    ).slideUpFade(delay: AppAnimations.medium),
                    const SizedBox(height: 32),

                    // 4. Action Section
                    Text(
                      'Start Learning',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: isDarkMode
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ).slideUpFade(
                      delay: AppAnimations.medium + AppAnimations.staggerLow,
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
                    ).slideUpFade(
                      delay: AppAnimations.medium + AppAnimations.staggerMedium,
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
                    ).slideUpFade(delay: AppAnimations.slow),
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
        ),
      ),
    );
  }
}
