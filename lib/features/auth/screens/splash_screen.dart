import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkNavigation();
  }

  Future<void> _checkNavigation() async {
    // Wait for animations + artificial delay
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final bool onboardingSeen = prefs.getBool('onboardingSeen') ?? false;

    final authState = ref.read(authProvider);

    if (authState.isAuthenticated) {
      context.go('/'); // Home
    } else {
      if (onboardingSeen) {
        context.go('/login');
      } else {
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundDark,
              Color(0xFF2D1B4E), // Deep purple
            ],
          ),
        ),
        child: Stack(
          children: [
            // Floating Notes Background
            ...List.generate(5, (index) {
              final align = [
                const Alignment(-0.8, -0.6),
                const Alignment(0.8, -0.7),
                const Alignment(-0.5, 0.4),
                const Alignment(0.7, 0.5),
                const Alignment(0.2, -0.2),
              ][index];
              return Align(
                alignment: align,
                child:
                    Icon(
                          Icons.music_note,
                          color: Colors.white.withValues(alpha: 0.1),
                          size: (index % 2 == 0) ? 30 : 50,
                        )
                        .animate(
                          onPlay: (controller) =>
                              controller.repeat(reverse: true),
                        )
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.2, 1.2),
                          duration: 2.seconds,
                          delay: (index * 300).ms,
                        )
                        .rotate(begin: -0.1, end: 0.1, duration: 3.seconds),
              );
            }),

            // Main Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Placeholder (Piano Keys)
                  Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.piano,
                          size: 50,
                          color: Colors.white,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        duration: 800.ms,
                        curve: Curves.easeOutBack,
                      ),

                  const SizedBox(height: 24),

                  Text(
                        'Melodify',
                        style: AppTextStyles.displayLarge.copyWith(
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 800.ms)
                      .slideY(
                        begin: 0.5,
                        end: 0,
                        duration: 800.ms,
                        curve: Curves.easeOutQuart,
                      ),

                  const SizedBox(height: 8),

                  Text(
                    'Master the Keys',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ).animate().fadeIn(delay: 800.ms, duration: 800.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
