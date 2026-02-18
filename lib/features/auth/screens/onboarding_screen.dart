import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _contents = [
    OnboardingContent(
      title: 'Learn Piano with Ease',
      description:
          'Start your musical journey with step-by-step interactive lessons designed for beginners.',
      icon: Icons.music_note_rounded,
    ),
    OnboardingContent(
      title: 'Practice Smarter',
      description:
          'Get real-time feedback on your playing accuracy and track your improvements over time.',
      icon: Icons.timer_outlined,
    ),
    OnboardingContent(
      title: 'Track Your Progress',
      description:
          'Visualize your daily streaks, complete achievements, and level up your skills.',
      icon: Icons.trending_up_rounded,
    ),
  ];

  Future<void> _completeOnboarding({bool asGuest = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingSeen', true);
    
    if (asGuest) {
      await ref.read(authProvider.notifier).setGuestMode(true);
      if (!mounted) return;
      context.go('/');
    } else {
      if (!mounted) return;
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => _completeOnboarding(asGuest: true),
            child: Text(
              'Skip',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _contents.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  // Re-animate content when page changes by using unique keys if needed,
                  // but PageView handles building/disposing so standard animate should trigger on build.
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                              padding: const EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                color: AppColors.primaryPurple.withValues(
                                  alpha: 0.1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _contents[index].icon,
                                size: 100,
                                color: AppColors.primaryPurple,
                              ),
                            )
                            .animate(key: ValueKey('icon_$index'))
                            .scale(duration: 500.ms, curve: Curves.easeOutBack)
                            .fadeIn(duration: 500.ms),

                        const SizedBox(height: 48),

                        Text(
                              _contents[index].title,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.headlineMedium.copyWith(
                                color: AppColors.textPrimaryLight,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                            .animate(key: ValueKey('title_$index'))
                            .fadeIn(delay: 200.ms, duration: 500.ms)
                            .slideY(
                              begin: 0.2,
                              end: 0,
                              duration: 500.ms,
                              curve: Curves.easeOut,
                            ),

                        const SizedBox(height: 16),

                        Text(
                              _contents[index].description,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textSecondaryLight,
                                height: 1.5,
                              ),
                            )
                            .animate(key: ValueKey('desc_$index'))
                            .fadeIn(delay: 400.ms, duration: 500.ms)
                            .slideY(
                              begin: 0.2,
                              end: 0,
                              duration: 500.ms,
                              curve: Curves.easeOut,
                            ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _contents.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primaryPurple
                              : AppColors.textTertiary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: 32),

                  // On last slide, show both buttons
                  if (_currentPage == _contents.length - 1)
                    Column(
                      children: [
                        CustomButton(
                          text: 'Get Started',
                          onPressed: () => _completeOnboarding(asGuest: false),
                          width: double.infinity,
                        ).animate(
                          target: 1,
                        ).shimmer(
                          duration: 2.seconds,
                          color: Colors.white.withValues(alpha: 0.5),
                        ).animate(onPlay: (c) => c.repeat(reverse: true))
                        .scaleXY(
                          end: 1.05,
                          duration: 1.seconds,
                          curve: Curves.easeInOut,
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => _completeOnboarding(asGuest: true),
                          child: Text(
                            'Continue as Guest',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ).animate().fadeIn(delay: 200.ms),
                      ],
                    )
                  else
                    CustomButton(
                      text: 'Next',
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      width: double.infinity,
                    ).animate().shimmer(
                      duration: 2.seconds,
                      color: Colors.white.withValues(alpha: 0.5),
                    ).animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(
                      end: 1.05,
                      duration: 1.seconds,
                      curve: Curves.easeInOut,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingContent {
  final String title;
  final String description;
  final IconData icon;

  OnboardingContent({
    required this.title,
    required this.description,
    required this.icon,
  });
}
