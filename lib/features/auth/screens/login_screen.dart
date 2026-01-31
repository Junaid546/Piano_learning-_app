import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authProvider.notifier)
          .login(_emailController.text.trim(), _passwordController.text);

      // Navigation is handled by router based on auth state changes
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Show error snackbar if needed
    ref.listen(authProvider, (previous, next) {
      if (next.errorMessage != null && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Logo & Title
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.piano_rounded,
                      size: 48,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue your progress',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 48),

                // Form Fields
                CustomTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: _emailController,
                  validator: Validators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  validator: Validators.validatePassword,
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline),
                ),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password dialog/screen
                    },
                    child: Text(
                      'Forgot Password?',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Login Button
                CustomButton(
                  text: 'Login',
                  onPressed: _onLogin,
                  isLoading: authState.isLoading,
                ),

                const SizedBox(height: 24),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/signup'),
                      child: Text(
                        'Sign Up',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
