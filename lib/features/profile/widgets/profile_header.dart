import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/glass_container.dart';

class ProfileHeader extends StatelessWidget {
  final String? profileImageUrl;
  final String displayName;
  final String email;
  final DateTime? memberSince;
  final VoidCallback onEditTap;
  final VoidCallback? onImageTap;
  final VoidCallback? onShareTap;

  const ProfileHeader({
    super.key,
    this.profileImageUrl,
    required this.displayName,
    required this.email,
    this.memberSince,
    required this.onEditTap,
    this.onImageTap,
    this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Column(
        children: [
          // Glowing Profile Picture
          Stack(
            alignment: Alignment.center,
            children: [
              // Glow effect
              Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primaryPurple.withOpacity(0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.1, 1.1),
                    duration: 2.seconds,
                  ),

              // Avatar Border
              Container(
                width: 110,
                height: 110,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.2),
                    ],
                  ),
                ),
                child: GestureDetector(
                  onTap: onImageTap,
                  child: Hero(
                    tag: 'profile_avatar',
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: profileImageUrl != null
                          ? Image.network(profileImageUrl!, fit: BoxFit.cover)
                          : Container(
                              color: AppColors.surfaceLight,
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: AppColors.primaryPurple.withOpacity(0.5),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // User info in Glass Card
          GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            opacity: 0.05,
            borderRadius: BorderRadius.circular(24),
            child: Column(
              children: [
                Text(
                  displayName,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  email,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : AppColors.textSecondaryLight,
                  ),
                ),
                if (memberSince != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryPurple.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.workspace_premium, // Changed icon for flair
                          size: 16,
                          color: AppColors.primaryPurple,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Member since ${_formatDate(memberSince!)}',
                          style: const TextStyle(
                            color: AppColors.primaryPurple,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 20),

          // Action Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(
                context,
                icon: Icons.edit_rounded,
                label: 'Edit',
                onTap: onEditTap,
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                context,
                icon: Icons.share_rounded,
                label: 'Share',
                onTap: onShareTap ?? () {},
              ),
            ],
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        borderRadius: BorderRadius.circular(16),
        color: AppColors.primaryPurple.withOpacity(0.1),
        border: Border.all(color: AppColors.primaryPurple.withOpacity(0.3)),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isDark ? Colors.white : AppColors.primaryPurple,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.primaryPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
