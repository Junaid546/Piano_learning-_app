import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// Notification service for daily reminders and achievements
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize the notification service
  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();
  }

  /// Request notification permissions
  static Future<void> _requestPermissions() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    // Handle navigation based on payload
    if (response.payload != null) {
      // TODO: Navigate to specific screen based on payload
      print('Notification tapped with payload: ${response.payload}');
    }
  }

  /// Schedule daily practice reminder
  static Future<void> scheduleDailyPracticeReminder({
    required int hour,
    required int minute,
  }) async {
    await _notifications.zonedSchedule(
      0, // Notification ID
      'Time to Practice! 🎹',
      'Keep your streak going. Practice makes perfect!',
      _scheduleDailyTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Practice Reminder',
          channelDescription: 'Reminds you to practice piano daily',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancel daily practice reminder
  static Future<void> cancelDailyPracticeReminder() async {
    await _notifications.cancel(0);
  }

  /// Show streak warning notification
  static Future<void> showStreakWarning(int currentStreak) async {
    await _notifications.show(
      1, // Notification ID
      'Don\'t Break Your Streak! 🔥',
      'You\'re on a $currentStreak day streak! Practice today to keep it going.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'streak_warning',
          'Streak Warnings',
          channelDescription:
              'Warns when your practice streak is about to break',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Show achievement unlocked notification
  static Future<void> showAchievementUnlocked({
    required String title,
    required String description,
  }) async {
    await _notifications.show(
      2, // Notification ID
      'Achievement Unlocked! 🏆',
      '$title - $description',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'achievements',
          'Achievements',
          channelDescription: 'Notifications for unlocked achievements',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'achievement',
    );
  }

  /// Show lesson completion notification
  static Future<void> showLessonCompleted(String lessonTitle) async {
    await _notifications.show(
      3, // Notification ID
      'Lesson Completed! ✅',
      'Great job completing "$lessonTitle"!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'lesson_completion',
          'Lesson Completion',
          channelDescription: 'Notifications for completed lessons',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Show level up notification
  static Future<void> showLevelUp(int newLevel) async {
    await _notifications.show(
      4, // Notification ID
      'Level Up! 🎉',
      'Congratulations! You\'ve reached Level $newLevel!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'level_up',
          'Level Up',
          channelDescription: 'Notifications for leveling up',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Helper to schedule daily time
  static tz.TZDateTime _scheduleDailyTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the scheduled time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}

/// Provider for notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
