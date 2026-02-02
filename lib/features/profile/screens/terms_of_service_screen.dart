import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader('Last updated: February 2024', isDark),
              const SizedBox(height: 24),
              _buildSection('1. Acceptance of Terms', isDark, '''
By downloading and using the Melodify mobile application ("App"), you agree to be bound by these Terms of Service ("Terms"). If you do not agree to these Terms, do not use the App.
'''),
              const SizedBox(height: 16),
              _buildSection('2. Description of Service', isDark, '''
Melodify is a piano learning application that provides interactive lessons, practice tools, and progress tracking features. The App is provided "as is" and we reserve the right to modify, suspend, or discontinue any aspect of the service at any time.
'''),
              const SizedBox(height: 16),
              _buildSection('3. User Accounts', isDark, '''
To use certain features of the App, you must create an account. You agree to:

• Provide accurate, current, and complete information during registration

• Maintain the security of your password and account

• Accept responsibility for all activities under your account

• Notify us immediately of any unauthorized use of your account

We reserve the right to terminate accounts that violate these Terms.
'''),
              const SizedBox(height: 16),
              _buildSection('4. Subscription and Payments', isDark, '''
Some features of Melodify require a paid subscription. By subscribing, you agree to:

• Pay all fees associated with your chosen subscription plan

• Automatic renewal unless cancelled at least 24 hours before the end of the current period

• Subscription fees are non-refundable except as required by law

• Prices are subject to change with 30 days notice
'''),
              const SizedBox(height: 16),
              _buildSection('5. User Conduct', isDark, '''
When using Melodify, you agree NOT to:

• Use the App for any unlawful purpose

• Attempt to gain unauthorized access to our systems or networks

• Transmit viruses, malware, or other harmful code

• Interfere with or disrupt the Apps functionality

• Copy, modify, or distribute any content without permission

• Use automated systems to access the App without authorization
'''),
              const SizedBox(height: 16),
              _buildSection('6. Intellectual Property', isDark, '''
All content, features, and functionality of the App (including but not limited to text, graphics, logos, icons, images, audio clips, and software) are owned by Melodify or its licensors and are protected by copyright, trademark, and other intellectual property laws.

You may not use our trademarks, trade names, or copyrighted materials without our prior written consent.
'''),
              const SizedBox(height: 16),
              _buildSection('7. User Generated Content', isDark, '''
You retain ownership of content you create within the App (such as practice recordings). By using the App, you grant us a non-exclusive, worldwide, royalty-free license to use, reproduce, and display such content for the purpose of providing and improving our services.
'''),
              const SizedBox(height: 16),
              _buildSection('8. Privacy', isDark, '''
Your use of the App is also governed by our Privacy Policy, which explains how we collect, use, and protect your information. By using the App, you consent to our collection and use of information as described in the Privacy Policy.
'''),
              const SizedBox(height: 16),
              _buildSection('9. Disclaimers', isDark, '''
THE APP IS PROVIDED "AS IS" AND "AS AVAILABLE" WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED. WE DO NOT WARRANT THAT THE APP WILL BE UNINTERRUPTED, TIMELY, SECURE, OR ERROR-FREE.

We do not guarantee any specific learning outcomes or results from using the App.
'''),
              const SizedBox(height: 16),
              _buildSection('10. Limitation of Liability', isDark, '''
TO THE MAXIMUM EXTENT PERMITTED BY LAW, MELODIFY SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, OR ANY LOSS OF PROFITS OR REVENUES, WHETHER INCURRED DIRECTLY OR INDIRECTLY.

In any event, our total liability shall not exceed the amount paid by you for the App in the twelve months preceding the claim.
'''),
              const SizedBox(height: 16),
              _buildSection('11. Termination', isDark, '''
We may terminate or suspend your account and access to the App at our sole discretion, without prior notice, for conduct that we believe violates these Terms or is harmful to other users, us, or third parties.

Upon termination, your right to use the App will immediately cease. Provisions that should survive termination include intellectual property rights, disclaimers, and limitation of liability.
'''),
              const SizedBox(height: 16),
              _buildSection('12. Governing Law', isDark, '''
These Terms shall be governed by and construed in accordance with applicable laws, without regard to conflict of law principles.
'''),
              const SizedBox(height: 16),
              _buildSection('13. Changes to Terms', isDark, '''
We reserve the right to modify these Terms at any time. Material changes will be notified through the App or by email. Your continued use of the App after any such changes constitutes acceptance of the new Terms.
'''),
              const SizedBox(height: 16),
              _buildSection('14. Contact Information', isDark, '''
If you have any questions about these Terms, please contact us at:

Email: legal@melodify.app
'''),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  '© 2024 Melodify. All rights reserved.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? Colors.white54 : Colors.black38,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String text, bool isDark) {
    return Text(
      text,
      style: AppTextStyles.bodyMedium.copyWith(
        color: isDark ? Colors.white54 : Colors.black38,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildSection(String title, bool isDark, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content.trim(),
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
