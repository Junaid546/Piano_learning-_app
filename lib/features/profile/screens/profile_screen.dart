import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../auth/providers/auth_provider.dart';
import '../../progress/providers/progress_provider.dart';
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

    if (userAsync.userModel == null) {
      return const Scaffold(body: Center(child: LoadingIndicator()));
    }

    final user = userAsync.userModel!;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              ProfileHeader(
                profileImageUrl: user.profileImageUrl,
                displayName: user.displayName ?? 'User',
                email: user.email,
                memberSince: user.createdAt,
                onEditTap: () {
                  // Navigate to edit profile
                  context.push('/profile/edit');
                },
                onImageTap: () {
                  // Show full image or change picture
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
              fontFamily: 'Inter',
            ),
          ),
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
            // TODO: Implement password change
            _showComingSoonDialog();
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
            // TODO: Open privacy policy
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
            // TODO: Open terms
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
        ),
        SettingsTile(
          icon: Icons.play_circle,
          iconColor: Colors.purple,
          title: 'Tutorial Replay',
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
          ),
          onTap: () {
            // TODO: Replay tutorial
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
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(profileActionsProvider).deleteAccount();
                if (mounted) {
                  context.go('/login');
                }
              } catch (e) {
                // Show error
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: const Text('This feature is coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
