import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
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

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingSeen', true);
    if (!mounted) return;
    context.go('/login');
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
            onPressed: _completeOnboarding,
            child: Text(
              'Skip',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
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
                        ),
                        const SizedBox(height: 48),
                        Text(
                          _contents[index].title,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.textPrimaryLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _contents[index].description,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondaryLight,
                            height: 1.5,
                          ),
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
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: _currentPage == _contents.length - 1
                        ? 'Get Started'
                        : 'Next',
                    onPressed: () {
                      if (_currentPage == _contents.length - 1) {
                        _completeOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    width: double.infinity,
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
