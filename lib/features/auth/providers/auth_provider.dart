import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user_model.dart';
import '../models/auth_state.dart';
import '../../../database/sync_service.dart';

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
        state = AuthState.unauthenticated();
      }
    });
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

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Auth state listener will handle the rest
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _handleAuthException(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred',
      );
    }
  }

  Future<void> signup({
    required String email,
    required String password,
    required String fullName,
  }) async {
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

        // Create initial progress document
        await _firestore.collection('progress').doc(cred.user!.uid).set({
          'lessonsCompleted': [],
          'practiceAttempts': 0,
          'totalPracticeTime': 0,
          'currentStreak': 0,
          'lastPracticeDate': null,
          'achievements': [],
        });

        // Auth state listener will pick up the change, but model might take a moment
        state = AuthState.authenticated(cred.user!, newUser);
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _handleAuthException(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred',
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    // Clear SQLite cache on logout
    final syncService = SyncService();
    await syncService.clearCache();

    await _auth.signOut();
    // Listener will update state
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _auth.sendPasswordResetEmail(email: email);
      state = state.copyWith(isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _handleAuthException(e),
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}
