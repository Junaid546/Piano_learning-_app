import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/models/user_model.dart';

class AuthState {
  final User? firebaseUser;
  final UserModel? userModel;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.firebaseUser,
    this.userModel,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated => firebaseUser != null;

  factory AuthState.initial() {
    return const AuthState();
  }

  factory AuthState.loading() {
    return const AuthState(isLoading: true);
  }

  factory AuthState.error(String message) {
    return AuthState(errorMessage: message);
  }

  factory AuthState.authenticated(User firebaseUser, UserModel? userModel) {
    return AuthState(firebaseUser: firebaseUser, userModel: userModel);
  }

  factory AuthState.unauthenticated() {
    return const AuthState();
  }

  AuthState copyWith({
    User? firebaseUser,
    UserModel? userModel,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      firebaseUser: firebaseUser ?? this.firebaseUser,
      userModel: userModel ?? this.userModel,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
