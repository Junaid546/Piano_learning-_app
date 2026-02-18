import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Screens
import '../features/home/home_screen.dart';
import '../features/home/main_scaffold.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/onboarding_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/lessons/screens/lessons_list_screen.dart';
import '../features/lessons/screens/lesson_detail_screen.dart';
import '../features/practice/screens/practice_mode_screen.dart';
import '../features/practice/screens/practice_results_screen.dart';
import '../features/progress/screens/progress_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/edit_profile_screen.dart';
import '../features/profile/screens/change_password_screen.dart';
import '../features/profile/screens/privacy_policy_screen.dart';
import '../features/profile/screens/terms_of_service_screen.dart';
import '../features/free_piano/screens/premium_landscape_piano_screen.dart';

// Models
import '../features/practice/models/practice_session.dart';

// Providers
import '../features/auth/providers/auth_provider.dart';
import '../features/lessons/providers/lessons_provider.dart';

/// Main router provider for the app
/// Handles all navigation, guards, and page transitions
final routerProvider = Provider<GoRouter>((ref) {
  // Create a notifier that will trigger router refresh on auth changes
  final notifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    debugLogDiagnostics: kDebugMode,

    // Global redirect logic for authentication
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.isAuthenticated;
      final isGuest = authState.isGuest;
      final location = state.matchedLocation;

      // Allow splash and onboarding to handle their own navigation
      if (location == '/splash' || location == '/onboarding') {
        return null;
      }

      // If logged in (but not guest), don't show auth pages
      // Guests can access signup to upgrade their account
      if (isLoggedIn && _isAuthRoute(location)) {
        return '/';
      }

      // If not logged in and not guest, redirect to onboarding
      if (!isLoggedIn && !isGuest && !_isAuthRoute(location)) {
        return '/onboarding';
      }

      return null;
    },

    routes: [
      // ==================== SPLASH SCREEN ====================
      GoRoute(
        path: '/splash',
        name: 'splash',
        pageBuilder: (context, state) =>
            _buildFadePage(key: state.pageKey, child: const SplashScreen()),
      ),

      // ==================== ONBOARDING SCREEN ====================
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        pageBuilder: (context, state) => _buildSlidePage(
          key: state.pageKey,
          child: const OnboardingScreen(),
        ),
      ),

      // ==================== AUTH SCREENS ====================
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) =>
            _buildSlidePage(key: state.pageKey, child: const LoginScreen()),
      ),

      GoRoute(
        path: '/signup',
        name: 'signup',
        pageBuilder: (context, state) =>
            _buildSlidePage(key: state.pageKey, child: const SignupScreen()),
      ),

      // ==================== MAIN APP WITH BOTTOM NAVIGATION ====================
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(location: state.matchedLocation, child: child);
        },
        routes: [
          // Home Screen
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),

          // Lessons List Screen
          GoRoute(
            path: '/lessons',
            name: 'lessons',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: LessonsListScreen()),
          ),

          // Practice Mode Screen
          GoRoute(
            path: '/practice',
            name: 'practice',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: PracticeModeScreen()),
          ),

          // Progress Screen
          GoRoute(
            path: '/progress',
            name: 'progress',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProgressScreen()),
          ),

          // Profile Screen
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),

      // ==================== LESSON DETAIL (Outside Shell) ====================
      GoRoute(
        path: '/lesson/:id',
        name: 'lesson-detail',
        pageBuilder: (context, state) {
          final lessonId = state.pathParameters['id']!;

          // Get lesson from provider
          final lessonsAsync = ref.read(lessonsProvider);

          return lessonsAsync.when(
            data: (lessons) {
              final lesson = lessons.firstWhere(
                (l) => l.id == lessonId,
                orElse: () => lessons.first, // Fallback to first lesson
              );

              return _buildSlidePage(
                key: state.pageKey,
                child: LessonDetailScreen(lesson: lesson),
              );
            },
            loading: () => _buildFadePage(
              key: state.pageKey,
              child: const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (_, __) => _buildFadePage(
              key: state.pageKey,
              child: const Scaffold(
                body: Center(child: Text('Error loading lesson')),
              ),
            ),
          );
        },
      ),

      // ==================== PRACTICE RESULTS (Outside Shell) ====================
      GoRoute(
        path: '/practice-results',
        name: 'practice-results',
        pageBuilder: (context, state) {
          // Get session from extra data
          final session = state.extra as PracticeSession?;

          if (session == null) {
            // Redirect to practice if no session data
            return _buildFadePage(
              key: state.pageKey,
              child: const PracticeModeScreen(),
            );
          }

          return _buildModalPage(
            key: state.pageKey,
            child: PracticeResultsScreen(session: session),
          );
        },
      ),

      // ==================== EDIT PROFILE (Outside Shell) ====================
      GoRoute(
        path: '/edit-profile',
        name: 'edit-profile',
        pageBuilder: (context, state) => _buildSlidePage(
          key: state.pageKey,
          child: const EditProfileScreen(),
        ),
      ),

      // ==================== CHANGE PASSWORD (Outside Shell) ====================
      GoRoute(
        path: '/change-password',
        name: 'change-password',
        pageBuilder: (context, state) => _buildSlidePage(
          key: state.pageKey,
          child: const ChangePasswordScreen(),
        ),
      ),

      // ==================== PRIVACY POLICY (Outside Shell) ====================
      GoRoute(
        path: '/privacy-policy',
        name: 'privacy-policy',
        pageBuilder: (context, state) => _buildSlidePage(
          key: state.pageKey,
          child: const PrivacyPolicyScreen(),
        ),
      ),

      // ==================== TERMS OF SERVICE (Outside Shell) ====================
      GoRoute(
        path: '/terms-of-service',
        name: 'terms-of-service',
        pageBuilder: (context, state) => _buildSlidePage(
          key: state.pageKey,
          child: const TermsOfServiceScreen(),
        ),
      ),

      // ==================== FREE PIANO (Landscape Mode) ====================
      GoRoute(
        path: '/free-piano',
        name: 'free-piano',
        pageBuilder: (context, state) => _buildFadePage(
          key: state.pageKey,
          child: const PremiumLandscapePianoScreen(),
        ),
      ),
    ],

    // Error page
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

// ==================== HELPER FUNCTIONS ====================

/// Check if route is an authentication route
bool _isAuthRoute(String location) {
  return location == '/login' || location == '/signup';
}

/// Build a page with fade transition
CustomTransitionPage _buildFadePage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

/// Build a page with slide transition (from right)
CustomTransitionPage _buildSlidePage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

/// Build a page with modal slide-up transition
CustomTransitionPage _buildModalPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeOutCubic;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}

// ==================== ROUTER NOTIFIER ====================

/// Notifier that listens to auth changes and refreshes the router
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    // Listen to auth provider changes
    _ref.listen(authProvider, (previous, next) {
      // Notify router when auth state changes
      notifyListeners();
    });
  }
}
