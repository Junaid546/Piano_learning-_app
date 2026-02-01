import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Centralized error handling for the app
class ErrorHandler {
  /// Get user-friendly error message from Exception
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      return _getFirebaseAuthErrorMessage(error);
    } else if (error is FirebaseException) {
      return _getFirebaseErrorMessage(error);
    } else if (error is NetworkException) {
      return 'Network error. Please check your internet connection.';
    } else if (error is AudioLoadException) {
      return 'Failed to load audio. Please try again.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Firebase Auth specific error messages
  static String _getFirebaseAuthErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return 'No account found with this email. Please sign up.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Contact support.';
      case 'invalid-credential':
        return 'Invalid credentials. Please try again.';
      default:
        return 'Authentication error: ${error.message ?? "Unknown error"}';
    }
  }

  /// Firebase general error messages
  static String _getFirebaseErrorMessage(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'You don\'t have permission to access this data.';
      case 'not-found':
        return 'The requested data was not found.';
      case 'already-exists':
        return 'This data already exists.';
      case 'unavailable':
        return 'Service temporarily unavailable. Please try again.';
      case 'data-loss':
        return 'Data loss occurred. Please contact support.';
      case 'unauthenticated':
        return 'Please sign in to continue.';
      case 'deadline-exceeded':
        return 'Request timed out. Please try again.';
      default:
        return 'Error: ${error.message ?? "Unknown error"}';
    }
  }

  /// Retry logic for async operations
  static Future<T> retry<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int attempt = 0;
    while (true) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        if (attempt >= maxAttempts) {
          rethrow;
        }
        await Future.delayed(delay * attempt);
      }
    }
  }
}

/// Custom exception for network errors
class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Network error occurred']);

  @override
  String toString() => message;
}

/// Custom exception for audio loading errors
class AudioLoadException implements Exception {
  final String message;
  final String? audioPath;

  AudioLoadException(this.message, [this.audioPath]);

  @override
  String toString() =>
      'AudioLoadException: $message${audioPath != null ? " (Path: $audioPath)" : ""}';
}

/// Custom exception for validation errors
class ValidationException implements Exception {
  final String message;
  final Map<String, String>? fieldErrors;

  ValidationException(this.message, [this.fieldErrors]);

  @override
  String toString() => message;
}
