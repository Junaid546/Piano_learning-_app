import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/user_model.dart';
import '../models/auth_state.dart';
import '../../../database/sync_service.dart';

/// User-friendly error messages for authentication
class AuthErrorMessages {
  static String getReadableError(String errorCode) {
    switch (errorCode) {
      // EMAIL ERRORS
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'user-not-found':
        return 'No account found with this email. Please sign up first.';
      case 'email-already-in-use':
        return 'This email is already registered. Try logging in instead.';

      // PASSWORD ERRORS
      case 'wrong-password':
        return 'Incorrect password. Please try again or reset your password.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters with letters and numbers.';
      case 'password-does-not-match':
        return 'Passwords do not match. Please check and try again.';

      // ACCOUNT ERRORS
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using a different sign-in method.';

      // NETWORK ERRORS
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please wait a few minutes and try again.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please contact support.';

      // VALIDATION ERRORS
      case 'email-empty':
        return 'Please enter your email address';
      case 'password-empty':
        return 'Please enter your password';
      case 'name-empty':
        return 'Please enter your name';
      case 'password-too-short':
        return 'Password must be at least 8 characters long';
      case 'password-no-uppercase':
        return 'Password must contain at least one uppercase letter';
      case 'password-no-lowercase':
        return 'Password must contain at least one lowercase letter';
      case 'password-no-number':
        return 'Password must contain at least one number';

      // TIMEOUT
      case 'timeout':
        return 'Request timed out. Please check your connection and try again.';

      // DEFAULT
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  // Get error with action suggestion
  static Map<String, String> getErrorWithAction(String errorCode) {
    String message = getReadableError(errorCode);
    String? action;

    switch (errorCode) {
      case 'user-not-found':
        action = 'Sign Up';
        break;
      case 'email-already-in-use':
        action = 'Login Instead';
        break;
      case 'wrong-password':
        action = 'Forgot Password?';
        break;
      case 'network-request-failed':
        action = 'Retry';
        break;
      case 'too-many-requests':
        action = 'Try Again Later';
        break;
    }

    return {
      'message': message,
      'action': action ?? 'OK',
    };
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial()) {
    _init();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _init() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _fetchUserModel(user);
      } else {
        _checkGuestMode();
      }
    });
    // Also check guest mode on init
    _checkGuestMode();
  }

  Future<void> _checkGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isGuest = prefs.getBool('is_guest_mode') ?? false;
    if (isGuest) {
      state = AuthState.guest();
    } else {
      state = AuthState.unauthenticated();
    }
  }

  /// Check if user is in guest mode
  Future<bool> get isGuestMode async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_guest_mode') ?? false;
  }

  /// Set guest mode
  Future<void> setGuestMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_guest_mode', value);
    if (value) {
      state = AuthState.guest();
    } else {
      state = AuthState.unauthenticated();
    }
  }

  /// Exit guest mode (prompt to sign up)
  Future<void> exitGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_guest_mode');
    state = AuthState.unauthenticated();
  }

  Future<void> _fetchUserModel(User firebaseUser) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Timeout'),
          );
      if (doc.exists && doc.data() != null) {
        final userModel = UserModel.fromJson(doc.data()!);
        state = AuthState.authenticated(firebaseUser, userModel);

        // Save user to cache for offline access
        final syncService = SyncService();
        await syncService.saveUserToCache(firebaseUser.uid, userModel.toJson());

        // Trigger background sync after successful login
        _syncDataInBackground(firebaseUser.uid);
      } else {
        // User authenticated but no profile yet (edge case)
        state = AuthState.authenticated(firebaseUser, null);
      }
    } catch (e) {
      // If Firestore fails (offline), try to load from SQLite cache
      print('Firestore fetch failed, loading from cache: $e');

      try {
        final syncService = SyncService();
        final cachedUser = await syncService.getUserFromCache(firebaseUser.uid);

        if (cachedUser != null) {
          // User found in cache, authenticate with cached data
          final cachedUserModel = UserModel.fromJson(
            cachedUser as Map<String, dynamic>,
          );
          state = AuthState.authenticated(firebaseUser, cachedUserModel);
          print('Loaded user from cache successfully');
        } else {
          // No cached data available, but we have Firebase User.
          // Fallback to temporary session using basic Firebase data.
          print(
            'No cache found. Falling back to temporary Firebase user data.',
          );

          final tempUserModel = UserModel(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            displayName: firebaseUser.displayName ?? 'User',
            profileImageUrl: firebaseUser.photoURL,
            createdAt: DateTime.now(), // Estimate
            lastLogin: DateTime.now(),
          );

          state = AuthState.authenticated(firebaseUser, tempUserModel);

          // Try to sync again in background if network returns
          _syncDataInBackground(firebaseUser.uid);
        }
      } catch (cacheError) {
        print('Cache fetch failed: $cacheError');
        // Even if cache fails completely, give them access if we have the firebaseUser
        final tempUserModel = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? 'User',
          profileImageUrl: firebaseUser.photoURL,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );
        state = AuthState.authenticated(firebaseUser, tempUserModel);
      }
    }
  }

  /// Sync data from Firebase to SQLite cache in background
  void _syncDataInBackground(String userId) {
    final syncService = SyncService();
    // Run sync in background without blocking UI
    Future.microtask(() => syncService.syncAllData(userId));
  }

  Future<bool> login(String email, String password) async {
    // Validation
    if (email.trim().isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AuthErrorMessages.getReadableError('email-empty'),
      );
      return false;
    }

    if (password.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AuthErrorMessages.getReadableError('password-empty'),
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AuthErrorMessages.getReadableError(e.code),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to sign in. Please check your credentials and try again.',
      );
      return false;
    }
  }

  Future<bool> signup({
    required String email,
    required String password,
    required String fullName,
  }) async {
    // Validation
    if (fullName.trim().isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AuthErrorMessages.getReadableError('name-empty'),
      );
      return false;
    }

    if (email.trim().isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AuthErrorMessages.getReadableError('email-empty'),
      );
      return false;
    }

    if (password.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AuthErrorMessages.getReadableError('password-empty'),
      );
      return false;
    }

    // Password strength validation
    if (password.length < 8) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AuthErrorMessages.getReadableError('password-too-short'),
      );
      return false;
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AuthErrorMessages.getReadableError('password-no-uppercase'),
      );
      return false;
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AuthErrorMessages.getReadableError('password-no-lowercase'),
      );
      return false;
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AuthErrorMessages.getReadableError('password-no-number'),
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (cred.user != null) {
        final newUser = UserModel(
          id: cred.user!.uid,
          email: email,
          displayName: fullName,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        // Create user document
        await _firestore
            .collection('users')
            .doc(cred.user!.uid)
            .set(newUser.toJson());

        // Create initial progress document for new user
        await _firestore.collection('progress').doc(cred.user!.uid).set({
          'userId': cred.user!.uid,
          'completedLessonIds': [],
          'lessonsCompleted': 0,
          'totalLessons': 0,
          'practiceAttempts': 0,
          'totalPracticeTime': 0,
          'currentStreak': 0,
          'longestStreak': 0,
          'accuracy': 0.0,
          'level': 1,
          'xp': 0,
          'achievementsUnlocked': [],
          'lastPracticeDate': null,
          'practiceDates': {},
        });

        state = AuthState.authenticated(cred.user!, newUser);
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AuthErrorMessages.getReadableError(e.code),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred. Please try again.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    // Get current userId before signing out
    final currentUserId = _auth.currentUser?.uid;

    // Clear SQLite cache for current user on logout
    final syncService = SyncService();
    if (currentUserId != null) {
      await syncService.clearUserCache(currentUserId);
    } else {
      await syncService.clearCache();
    }

    await _auth.signOut();
    // Listener will update state
  }

  Future<void> resetPassword(String email) async {
    if (email.trim().isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AuthErrorMessages.getReadableError('email-empty'),
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _auth.sendPasswordResetEmail(email: email);
      state = state.copyWith(isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AuthErrorMessages.getReadableError(e.code),
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
