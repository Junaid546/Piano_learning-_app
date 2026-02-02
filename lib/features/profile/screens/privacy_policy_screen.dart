import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
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
              _buildSection('1. Introduction', isDark, '''
Welcome to Melodify ("we," "our," or "us"). We are committed to protecting your personal information and your right to privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and related services.

By downloading and using our app, you agree to the collection and use of information in accordance with this policy.
'''),
              const SizedBox(height: 16),
              _buildSection('2. Information We Collect', isDark, '''
We may collect information that you provide directly to us, including:

• Account Information: When you create an account, we collect your name, email address, and profile picture.

• User Content: Information you provide when using our piano learning features, including practice progress, lesson completions, and achievements.

• Usage Data: Information about how you interact with our app, including features used, time spent, and performance metrics.

• Device Information: Information about your device, including device type, operating system, and unique device identifiers.
'''),
              const SizedBox(height: 16),
              _buildSection('3. How We Use Your Information', isDark, '''
We use the information we collect to:

• Provide, maintain, and improve our piano learning services

• Track your progress and personalize your learning experience

• Send you updates about new features, lessons, and promotions

• Respond to your comments, questions, and support requests

• Analyze usage patterns to enhance app performance

• Detect, prevent, and address technical issues and fraud
'''),
              const SizedBox(height: 16),
              _buildSection('4. Data Storage and Security', isDark, '''
Your data is stored securely using Firebase services. We implement appropriate technical and organizational security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.

However, no method of transmission over the Internet or electronic storage is 100% secure. While we strive to protect your information, we cannot guarantee absolute security.
'''),
              const SizedBox(height: 16),
              _buildSection('5. Data Sharing and Disclosure', isDark, '''
We do not sell your personal information. We may share your information with:

• Service Providers: Third-party vendors who perform services on our behalf (e.g., cloud hosting, analytics)

• Legal Requirements: When required by law, subpoena, or other legal process

• Business Transfers: In connection with a merger, acquisition, or sale of assets

• With Your Consent: When you authorize us to share information
'''),
              const SizedBox(height: 16),
              _buildSection('6. Your Rights', isDark, '''
Depending on your location, you may have certain rights regarding your personal information:

• Access: Request a copy of the personal data we hold about you

• Correction: Request correction of inaccurate or incomplete data

• Deletion: Request deletion of your personal data

• Data Portability: Request a copy of your data in a machine-readable format

• Withdraw Consent: Withdraw your consent at any time
'''),
              const SizedBox(height: 16),
              _buildSection('7. Children is Privacy', isDark, '''
Our app is not intended for users under the age of 13. We do not knowingly collect personal information from children under 13. If you are a parent or guardian and believe your child has provided us with personal information, please contact us immediately.
'''),
              const SizedBox(height: 16),
              _buildSection('8. Changes to This Policy', isDark, '''
We may update this Privacy Policy from time to time. We will notify you of any material changes by posting the new Privacy Policy on this page and updating the "Last updated" date at the top of this policy.
'''),
              const SizedBox(height: 16),
              _buildSection('9. Contact Us', isDark, '''
If you have questions about this Privacy Policy or our data practices, please contact us at:

Email: privacy@melodify.app
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
