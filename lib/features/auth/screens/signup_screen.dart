import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSignup() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
        return;
      }

      await ref
          .read(authProvider.notifier)
          .signup(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _nameController.text.trim(),
          );

      // Auto-navigation by router
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
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryLight),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Start your musical journey today',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 32),

                CustomTextField(
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  controller: _nameController,
                  validator: Validators.validateRequired,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                const SizedBox(height: 16),

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
                  hint: 'Create a strong password',
                  controller: _passwordController,
                  validator: Validators.validatePassword,
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Confirm Password',
                  hint: 'Repeat your password',
                  controller: _confirmPasswordController,
                  validator: (val) {
                    if (val == null || val.isEmpty)
                      return 'Please confirm password';
                    if (val != _passwordController.text)
                      return 'Passwords do not match';
                    return null;
                  },
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline),
                ),

                const SizedBox(height: 48),

                CustomButton(
                  text: 'Sign Up',
                  onPressed: _onSignup,
                  isLoading: authState.isLoading,
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        'Login',
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
