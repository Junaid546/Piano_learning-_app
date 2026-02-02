import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/animated_background.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/premium_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../progress/providers/progress_provider.dart';
import '../../piano/providers/audio_service_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authProvider);
    final preferencesAsync = ref.watch(userPreferencesProvider);
    final progressAsync = ref.watch(userProgressProvider);

    // Use firebase user as fallback when userModel is still loading
    final firebaseUser = userAsync.firebaseUser;
    if (firebaseUser == null) {
      return const Scaffold(body: Center(child: LoadingIndicator()));
    }

    // Create a display user - either from userModel or fallback from firebase user
    final displayName =
        userAsync.userModel?.displayName ?? firebaseUser.displayName ?? 'User';
    final email = userAsync.userModel?.email ?? firebaseUser.email ?? '';
    final profileImageUrl =
        userAsync.userModel?.profileImageUrl ?? firebaseUser.photoURL;
    final memberSince = userAsync.userModel?.createdAt ?? DateTime.now();

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                ProfileHeader(
                  profileImageUrl: profileImageUrl,
                  displayName: displayName,
                  email: email,
                  memberSince: memberSince,
                  onEditTap: () {
                    context.push('/edit-profile');
                  },
                  onImageTap: () {
                    // Show full image or change picture
                  },
                  onShareTap: () {
                    final progress = progressAsync.asData?.value;
                    final level = progress?.level ?? 1;
                    final lessons = progress?.lessonsCompleted ?? 0;

                    Share.share(
                      '🎵 I\'m learning piano on Melodify! 🎹\n'
                      'I\'ve reached Level $level and completed $lessons lessons!\n'
                      'Join me in mastering the piano! 🚀',
                      subject: 'My Melodify Progress',
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Stats Cards
                progressAsync.when(
                  data: (progress) => _buildStatsCards(progress),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                // Settings Sections
                preferencesAsync.when(
                  data: (preferences) => Column(
                    children: [
                      _buildAppPreferences(preferences),
                      _buildAudioSettings(),
                      _buildLearningSettings(preferences),
                      _buildAccountSection(),
                      _buildAboutSection(),
                      _buildLogoutSection(),
                      const SizedBox(height: 100), // Bottom padding
                    ],
                  ),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: LoadingIndicator(),
                    ),
                  ),
                  error: (error, stack) =>
                      Center(child: Text('Error loading preferences: $error')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Level',
              progress.level.toString(),
              Icons.star,
              AppColors.primaryPurple,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'XP',
              progress.xp.toString(),
              Icons.bolt,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Lessons',
              progress.lessonsCompleted.toString(),
              Icons.book,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Hours',
              (progress.totalPracticeTime / 60).toStringAsFixed(1),
              Icons.access_time,
              Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildAppPreferences(preferences) {
    final profileActions = ref.read(profileActionsProvider);

    return SettingsSection(
      title: 'App Preferences',
      icon: Icons.settings,
      children: [
        SettingsTile(
          icon: Icons.dark_mode,
          iconColor: Colors.indigo,
          title: 'Dark Mode',
          subtitle: 'Enable dark theme',
          trailing: AnimatedToggleSwitch(
            value: preferences.darkMode,
            onChanged: (value) {
              profileActions.updatePreferences(
                preferences.copyWith(darkMode: value),
              );
            },
          ),
        ),
        SettingsTile(
          icon: Icons.volume_up,
          iconColor: Colors.purple,
          title: 'Sound Effects',
          subtitle: 'Play sounds when tapping keys',
          trailing: AnimatedToggleSwitch(
            value: preferences.soundEffects,
            onChanged: (value) {
              profileActions.updatePreferences(
                preferences.copyWith(soundEffects: value),
              );
            },
          ),
        ),
        SettingsTile(
          icon: Icons.vibration,
          iconColor: Colors.pink,
          title: 'Haptic Feedback',
          subtitle: 'Vibrate on interactions',
          trailing: AnimatedToggleSwitch(
            value: preferences.hapticFeedback,
            onChanged: (value) {
              profileActions.updatePreferences(
                preferences.copyWith(hapticFeedback: value),
              );
            },
          ),
        ),
        SettingsTile(
          icon: Icons.notifications,
          iconColor: Colors.orange,
          title: 'Notifications',
          subtitle: 'Receive practice reminders',
          trailing: AnimatedToggleSwitch(
            value: preferences.notifications,
            onChanged: (value) {
              profileActions.updatePreferences(
                preferences.copyWith(notifications: value),
              );
            },
          ),
          showDivider: false,
        ),
      ],
    );
  }

  Widget _buildAudioSettings() {
    return SettingsSection(
      title: 'Audio Settings',
      icon: Icons.music_note,
      children: [
        // Volume Control
        Consumer(
          builder: (context, ref, child) {
            final volume = ref.watch(audioVolumeProvider);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.volume_up,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Volume',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                            Text(
                              '${(volume * 100).round()}%',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.primaryPurple,
                      inactiveTrackColor: Colors.grey.shade300,
                      thumbColor: AppColors.primaryPurple,
                      overlayColor: AppColors.primaryPurple.withValues(
                        alpha: 0.2,
                      ),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: volume,
                      min: 0.0,
                      max: 1.0,
                      divisions: 20,
                      label: '${(volume * 100).round()}%',
                      onChanged: (value) {
                        ref.read(audioVolumeProvider.notifier).setVolume(value);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const Divider(height: 1),
        // Test Sound Button
        SettingsTile(
          icon: Icons.play_circle,
          iconColor: Colors.green,
          title: 'Test Sound',
          subtitle: 'Play a sample note',
          onTap: () {
            final audioService = ref.read(audioServiceProvider);
            audioService.playTestSound();
          },
          showDivider: false,
        ),
      ],
    );
  }

  Widget _buildLearningSettings(preferences) {
    final profileActions = ref.read(profileActionsProvider);

    return SettingsSection(
      title: 'Learning Settings',
      icon: Icons.school,
      children: [
        SettingsTile(
          icon: Icons.flag,
          iconColor: Colors.green,
          title: 'Daily Practice Goal',
          subtitle: '${preferences.dailyGoal} minutes',
          onTap: () => _showDailyGoalDialog(preferences),
        ),
        SettingsTile(
          icon: Icons.alarm,
          iconColor: Colors.blue,
          title: 'Reminder Time',
          subtitle: preferences.reminderTime != null
              ? '${preferences.reminderTime!.hour.toString().padLeft(2, '0')}:${preferences.reminderTime!.minute.toString().padLeft(2, '0')}'
              : 'Not set',
          onTap: () => _showReminderTimePicker(preferences),
        ),
        SettingsTile(
          icon: Icons.speed,
          iconColor: Colors.red,
          title: 'Difficulty',
          subtitle: preferences.difficulty.toUpperCase(),
          onTap: () => _showDifficultyDialog(preferences),
        ),
        SettingsTile(
          icon: Icons.auto_awesome,
          iconColor: Colors.amber,
          title: 'Auto-Advance Lessons',
          subtitle: 'Automatically unlock next lesson',
          trailing: AnimatedToggleSwitch(
            value: preferences.autoAdvanceLessons,
            onChanged: (value) {
              profileActions.updatePreferences(
                preferences.copyWith(autoAdvanceLessons: value),
              );
            },
          ),
        ),
        SettingsTile(
          icon: Icons.label,
          iconColor: Colors.teal,
          title: 'Show Key Labels',
          subtitle: 'Display note names on keys',
          trailing: AnimatedToggleSwitch(
            value: preferences.showKeyLabels,
            onChanged: (value) {
              profileActions.updatePreferences(
                preferences.copyWith(showKeyLabels: value),
              );
            },
          ),
          showDivider: false,
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return SettingsSection(
      title: 'Account',
      icon: Icons.account_circle,
      children: [
        SettingsTile(
          icon: Icons.lock,
          iconColor: Colors.deepPurple,
          title: 'Change Password',
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
          ),
          onTap: () {
            context.push('/change-password');
          },
        ),
        SettingsTile(
          icon: Icons.privacy_tip,
          iconColor: Colors.blue,
          title: 'Privacy Policy',
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
          ),
          onTap: () {
            context.push('/privacy-policy');
          },
        ),
        SettingsTile(
          icon: Icons.description,
          iconColor: Colors.cyan,
          title: 'Terms of Service',
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
          ),
          onTap: () {
            context.push('/terms-of-service');
          },
        ),
        SettingsTile(
          icon: Icons.delete_forever,
          iconColor: Colors.red,
          title: 'Delete Account',
          subtitle: 'Permanently delete your account',
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
          ),
          onTap: () => _showDeleteAccountDialog(),
          showDivider: false,
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return SettingsSection(
      title: 'About',
      icon: Icons.info,
      children: [
        SettingsTile(
          icon: Icons.info_outline,
          iconColor: Colors.grey,
          title: 'App Version',
          subtitle: _appVersion.isNotEmpty ? _appVersion : 'Loading...',
        ),
        SettingsTile(
          icon: Icons.star,
          iconColor: Colors.amber,
          title: 'Rate the App',
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
          ),
          onTap: () {
            // TODO: Open app store
          },
        ),
        SettingsTile(
          icon: Icons.feedback,
          iconColor: Colors.orange,
          title: 'Send Feedback',
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
          ),
          onTap: () {
            // TODO: Open feedback form
          },
        ),
        SettingsTile(
          icon: Icons.help,
          iconColor: Colors.green,
          title: 'Help & Support',
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
          ),
          onTap: () {
            // TODO: Open help
          },
          showDivider: false,
        ),
      ],
    );
  }

  Widget _buildLogoutSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _showLogoutDialog(),
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  // Dialog methods
  void _showDailyGoalDialog(preferences) {
    int currentGoal = preferences.dailyGoal;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Daily Practice Goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$currentGoal minutes'),
              Slider(
                value: currentGoal.toDouble(),
                min: 5,
                max: 60,
                divisions: 11,
                label: '$currentGoal min',
                onChanged: (value) {
                  setState(() {
                    currentGoal = value.toInt();
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(profileActionsProvider)
                    .updatePreferences(
                      preferences.copyWith(dailyGoal: currentGoal),
                    );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showReminderTimePicker(preferences) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime:
          preferences.reminderTime ?? const TimeOfDay(hour: 9, minute: 0),
    );

    if (picked != null) {
      ref
          .read(profileActionsProvider)
          .updatePreferences(preferences.copyWith(reminderTime: picked));
    }
  }

  void _showDifficultyDialog(preferences) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Difficulty'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['easy', 'medium', 'hard'].map((difficulty) {
            return RadioListTile<String>(
              title: Text(difficulty.toUpperCase()),
              value: difficulty,
              groupValue: preferences.difficulty,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(profileActionsProvider)
                      .updatePreferences(
                        preferences.copyWith(difficulty: value),
                      );
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final authNotifier = ref.read(authProvider.notifier);
              await authNotifier.logout();
              if (mounted) {
                context.go('/login');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: BorderRadius.circular(24),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.errorRed,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Delete Account',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),
              PremiumButton(
                label: 'Delete Forever',
                color: AppColors.errorRed,
                icon: Icons.delete_forever,
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await ref.read(profileActionsProvider).deleteAccount();
                    if (mounted) {
                      context.go('/login');
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: AppColors.errorRed,
                        ),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
