import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user_model.dart';
import '../models/auth_state.dart';

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
          .get();
      if (doc.exists && doc.data() != null) {
        final userModel = UserModel.fromJson(doc.data()!);
        state = AuthState.authenticated(firebaseUser, userModel);
      } else {
        // User authenticated but no profile yet (edge case)
        state = AuthState.authenticated(firebaseUser, null);
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
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
