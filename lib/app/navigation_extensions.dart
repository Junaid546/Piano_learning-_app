import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/practice/models/practice_session.dart';

/// Navigation helper extensions for easy routing
/// Usage: context.goToLessonDetail('lesson-id')
extension AppNavigation on BuildContext {
  // ==================== NAVIGATION METHODS ====================

  /// Navigate to splash screen
  void goToSplash() => go('/splash');

  /// Navigate to onboarding screen
  void goToOnboarding() => go('/onboarding');

  /// Navigate to login screen
  void goToLogin() => go('/login');

  /// Navigate to signup screen
  void goToSignup() => go('/signup');

  /// Navigate to home screen
  void goToHome() => go('/');

  /// Navigate to lessons list
  void goToLessons() => go('/lessons');

  /// Navigate to lesson detail by ID
  void goToLessonDetail(String lessonId) => go('/lesson/$lessonId');

  /// Navigate to practice mode
  void goToPractice() => go('/practice');

  /// Navigate to practice results with session data
  void goToPracticeResults(PracticeSession session) {
    go('/practice-results', extra: session);
  }

  /// Navigate to progress screen
  void goToProgress() => go('/progress');

  /// Navigate to profile screen
  void goToProfile() => go('/profile');

  /// Navigate to edit profile screen
  void goToEditProfile() => go('/edit-profile');

  // ==================== PUSH METHODS (for stacking) ====================

  /// Push lesson detail (keeps current page in stack)
  void pushLessonDetail(String lessonId) => push('/lesson/$lessonId');

  /// Push edit profile (keeps current page in stack)
  void pushEditProfile() => push('/edit-profile');

  /// Push practice results (keeps current page in stack)
  void pushPracticeResults(PracticeSession session) {
    push('/practice-results', extra: session);
  }

  // ==================== UTILITY METHODS ====================

  /// Go back to previous screen
  void goBack() => pop();

  /// Check if can go back
  bool get canGoBack => canPop();

  /// Replace current route with home
  void replaceWithHome() => go('/');

  /// Replace current route with login
  void replaceWithLogin() => go('/login');
}

/// Route name constants for type-safe navigation
class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/';
  static const String lessons = '/lessons';
  static const String lessonDetail = '/lesson/:id';
  static const String practice = '/practice';
  static const String practiceResults = '/practice-results';
  static const String progress = '/progress';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';

  /// Build lesson detail route with ID
  static String lessonDetailWithId(String id) => '/lesson/$id';
}
