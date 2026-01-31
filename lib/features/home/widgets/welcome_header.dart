import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class WelcomeHeader extends StatelessWidget {
  final String userName;
  final String? profileImageUrl;
  final VoidCallback onProfileTap;

  const WelcomeHeader({
    super.key,
    required this.userName,
    this.profileImageUrl,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $userName! 👋',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textPrimaryLight,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ready to play some music?',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        Row(
          children: [
            // Notification Bell
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.textTertiary.withValues(alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded),
                color: AppColors.textPrimaryLight,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ),
            const SizedBox(width: 12),
            // Profile Image
            GestureDetector(
              onTap: onProfileTap,
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryPurple.withValues(alpha: 0.1),
                  image: profileImageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(profileImageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  border: Border.all(
                    color: AppColors.primaryPurple.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: profileImageUrl == null
                    ? const Icon(Icons.person, color: AppColors.primaryPurple)
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
