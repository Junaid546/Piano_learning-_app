import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Screens
import '../features/home/home_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/onboarding_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/lessons/screens/lessons_list_screen.dart';
// Auth Provider
import '../features/auth/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Create a notifier that will trigger router refresh
  final notifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/lessons',
        builder: (context, state) => const LessonsListScreen(),
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authProvider);

      final bool isLoggedIn = authState.isAuthenticated;
      final bool isLoggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';
      final bool isSplash = state.matchedLocation == '/splash';
      final bool isOnboarding = state.matchedLocation == '/onboarding';

      // If splash or onboarding, let the screens handle navigation logic
      if (isSplash || isOnboarding) return null;

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      if (isLoggedIn && isLoggingIn) {
        return '/';
      }

      return null;
    },
  );
});

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
