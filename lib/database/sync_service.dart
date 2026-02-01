import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'database_tables.dart';
import '../features/lessons/models/lesson.dart';
import '../features/progress/models/user_progress.dart';
import '../features/profile/models/user_preferences.dart';
import '../features/practice/models/practice_session.dart';

/// SyncService - Manages bidirectional sync between Firebase and SQLite
/// Firebase is the source of truth, SQLite is the cache
class SyncService {
  final DatabaseHelper _dbHelper = DatabaseHelper.getInstance();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== SYNC ALL DATA ====================

  /// Sync all user data from Firebase to SQLite
  /// Call this on app startup after authentication
  Future<void> syncAllData(String userId) async {
    try {
      await Future.wait([
        syncLessons(),
        syncUserProgress(userId),
        syncUserPreferences(userId),
        syncPracticeSessions(userId),
      ]);
      debugPrint('✅ All data synced successfully');
    } catch (e) {
      debugPrint('❌ Error syncing all data: $e');
      // Don't throw - app should work with cached data if sync fails
    }
  }

  // ==================== LESSONS SYNC ====================

  /// Sync lessons from Firebase to SQLite
  Future<void> syncLessons() async {
    try {
      final snapshot = await _firestore
          .collection('lessons')
          .orderBy('order')
          .get();

      final lessons = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return _lessonToSqlite(Lesson.fromJson(data));
      }).toList();

      if (lessons.isNotEmpty) {
        await _dbHelper.insertBatch(DatabaseTables.tableLessons, lessons);
        debugPrint('✅ Synced ${lessons.length} lessons');
      }
    } catch (e) {
      debugPrint('❌ Error syncing lessons: $e');
    }
  }

  /// Convert Lesson model to SQLite map
  Map<String, dynamic> _lessonToSqlite(Lesson lesson) {
    return _dbHelper.addSyncTimestamp({
      'id': lesson.id,
      'title': lesson.title,
      'category': lesson.category,
      'description': lesson.description,
      'difficulty': lesson.difficulty,
      'estimatedDuration': lesson.estimatedDuration,
      'order_num': lesson.order,
      'isCompleted': _dbHelper.boolToInt(lesson.isCompleted),
      'isLocked': _dbHelper.boolToInt(lesson.isLocked),
      'objectives': jsonEncode(lesson.objectives),
      'notesToLearn': jsonEncode(lesson.notesToLearn),
      'content': jsonEncode(lesson.content.toJson()),
      'createdAt': lesson.createdAt.toIso8601String(),
    });
  }

  /// Load lessons from SQLite cache
  Future<List<Lesson>> loadLessonsFromCache() async {
    try {
      final results = await _dbHelper.query(
        DatabaseTables.tableLessons,
        orderBy: 'order_num ASC',
      );

      return results.map((row) => _sqliteToLesson(row)).toList();
    } catch (e) {
      debugPrint('❌ Error loading lessons from cache: $e');
      return [];
    }
  }

  /// Convert SQLite map to Lesson model
  Lesson _sqliteToLesson(Map<String, dynamic> row) {
    return Lesson.fromJson({
      'id': row['id'],
      'title': row['title'],
      'category': row['category'],
      'description': row['description'],
      'difficulty': row['difficulty'],
      'estimatedDuration': row['estimatedDuration'],
      'order': row['order_num'],
      'isCompleted': _dbHelper.intToBool(row['isCompleted']),
      'isLocked': _dbHelper.intToBool(row['isLocked']),
      'objectives': jsonDecode(row['objectives']),
      'notesToLearn': jsonDecode(row['notesToLearn']),
      'content': jsonDecode(row['content']),
      'createdAt': row['createdAt'],
    });
  }

  // ==================== USER PROGRESS SYNC ====================

  /// Sync user progress from Firebase to SQLite
  Future<void> syncUserProgress(String userId) async {
    try {
      final doc = await _firestore.collection('progress').doc(userId).get();

      if (doc.exists) {
        final progress = UserProgress.fromJson(doc.data()!);
        await _dbHelper.insert(
          DatabaseTables.tableUserProgress,
          _userProgressToSqlite(progress),
        );
        debugPrint('✅ Synced user progress');
      }
    } catch (e) {
      debugPrint('❌ Error syncing user progress: $e');
    }
  }

  /// Convert UserProgress model to SQLite map
  Map<String, dynamic> _userProgressToSqlite(UserProgress progress) {
    return _dbHelper.addSyncTimestamp({
      'userId': progress.userId,
      'lessonsCompleted': progress.lessonsCompleted,
      'totalLessons': progress.totalLessons,
      'practiceAttempts': progress.practiceAttempts,
      'totalPracticeTime': progress.totalPracticeTime,
      'currentStreak': progress.currentStreak,
      'longestStreak': progress.longestStreak,
      'accuracy': progress.accuracy,
      'level': progress.level,
      'xp': progress.xp,
      'achievementsUnlocked': jsonEncode(progress.achievementsUnlocked),
      'lastPracticeDate': progress.lastPracticeDate?.toIso8601String(),
      'practiceDates': jsonEncode(progress.practiceDates),
    });
  }

  /// Load user progress from SQLite cache
  Future<UserProgress?> loadUserProgressFromCache(String userId) async {
    try {
      final result = await _dbHelper.queryOne(
        DatabaseTables.tableUserProgress,
        'userId = ?',
        [userId],
      );

      if (result != null) {
        return _sqliteToUserProgress(result);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error loading user progress from cache: $e');
      return null;
    }
  }

  /// Convert SQLite map to UserProgress model
  UserProgress _sqliteToUserProgress(Map<String, dynamic> row) {
    return UserProgress.fromJson({
      'userId': row['userId'],
      'lessonsCompleted': row['lessonsCompleted'],
      'totalLessons': row['totalLessons'],
      'practiceAttempts': row['practiceAttempts'],
      'totalPracticeTime': row['totalPracticeTime'],
      'currentStreak': row['currentStreak'],
      'longestStreak': row['longestStreak'],
      'accuracy': row['accuracy'],
      'level': row['level'],
      'xp': row['xp'],
      'achievementsUnlocked': jsonDecode(row['achievementsUnlocked']),
      'lastPracticeDate': row['lastPracticeDate'],
      'practiceDates': jsonDecode(row['practiceDates']),
    });
  }

  // ==================== USER PREFERENCES SYNC ====================

  /// Sync user preferences from Firebase to SQLite
  Future<void> syncUserPreferences(String userId) async {
    try {
      final doc = await _firestore
          .collection('user_preferences')
          .doc(userId)
          .get();

      if (doc.exists) {
        final prefs = UserPreferences.fromJson(doc.data()!);
        await _dbHelper.insert(
          DatabaseTables.tableUserPreferences,
          _userPreferencesToSqlite(prefs),
        );
        debugPrint('✅ Synced user preferences');
      }
    } catch (e) {
      debugPrint('❌ Error syncing user preferences: $e');
    }
  }

  /// Convert UserPreferences model to SQLite map
  Map<String, dynamic> _userPreferencesToSqlite(UserPreferences prefs) {
    return _dbHelper.addSyncTimestamp({
      'userId': prefs.userId,
      'darkMode': _dbHelper.boolToInt(prefs.darkMode),
      'soundEffects': _dbHelper.boolToInt(prefs.soundEffects),
      'hapticFeedback': _dbHelper.boolToInt(prefs.hapticFeedback),
      'notifications': _dbHelper.boolToInt(prefs.notifications),
      'dailyGoal': prefs.dailyGoal,
      'reminderTime': prefs.reminderTime != null
          ? '${prefs.reminderTime!.hour.toString().padLeft(2, '0')}:${prefs.reminderTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'difficulty': prefs.difficulty,
      'autoAdvanceLessons': _dbHelper.boolToInt(prefs.autoAdvanceLessons),
      'showKeyLabels': _dbHelper.boolToInt(prefs.showKeyLabels),
      'language': prefs.language,
    });
  }

  /// Load user preferences from SQLite cache
  Future<UserPreferences?> loadUserPreferencesFromCache(String userId) async {
    try {
      final result = await _dbHelper.queryOne(
        DatabaseTables.tableUserPreferences,
        'userId = ?',
        [userId],
      );

      if (result != null) {
        return _sqliteToUserPreferences(result);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error loading user preferences from cache: $e');
      return null;
    }
  }

  /// Convert SQLite map to UserPreferences model
  UserPreferences _sqliteToUserPreferences(Map<String, dynamic> row) {
    return UserPreferences.fromJson({
      'userId': row['userId'],
      'darkMode': _dbHelper.intToBool(row['darkMode']),
      'soundEffects': _dbHelper.intToBool(row['soundEffects']),
      'hapticFeedback': _dbHelper.intToBool(row['hapticFeedback']),
      'notifications': _dbHelper.intToBool(row['notifications']),
      'dailyGoal': row['dailyGoal'],
      'reminderTime': row['reminderTime'],
      'difficulty': row['difficulty'],
      'autoAdvanceLessons': _dbHelper.intToBool(row['autoAdvanceLessons']),
      'showKeyLabels': _dbHelper.intToBool(row['showKeyLabels']),
      'language': row['language'],
    });
  }

  // ==================== PRACTICE SESSIONS SYNC ====================

  /// Sync practice sessions from Firebase to SQLite
  /// Only syncs recent sessions (last 30 days) to avoid large data transfer
  Future<void> syncPracticeSessions(String userId) async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      final snapshot = await _firestore
          .collection('practice_sessions')
          .where('userId', isEqualTo: userId)
          .where('startTime', isGreaterThan: thirtyDaysAgo.toIso8601String())
          .get();

      final sessions = snapshot.docs.map((doc) {
        final data = doc.data();
        data['sessionId'] = doc.id;
        return _practiceSessionToSqlite(PracticeSession.fromJson(data));
      }).toList();

      if (sessions.isNotEmpty) {
        await _dbHelper.insertBatch(
          DatabaseTables.tablePracticeSessions,
          sessions,
        );
        debugPrint('✅ Synced ${sessions.length} practice sessions');
      }
    } catch (e) {
      debugPrint('❌ Error syncing practice sessions: $e');
    }
  }

  /// Convert PracticeSession model to SQLite map
  Map<String, dynamic> _practiceSessionToSqlite(PracticeSession session) {
    return _dbHelper.addSyncTimestamp({
      'sessionId': session.sessionId,
      'userId': '', // Will be set by caller
      'startTime': session.startTime.toIso8601String(),
      'endTime': session.endTime?.toIso8601String(),
      'totalAttempts': session.totalAttempts,
      'correctAttempts': session.correctAttempts,
      'score': session.score,
      'accuracy': session.accuracy,
      'notesPlayed': jsonEncode(session.notesPlayed),
      'difficulty': session.difficulty,
      'longestStreak': session.longestStreak,
    });
  }

  /// Save practice session to cache
  Future<void> savePracticeSessionToCache(
    PracticeSession session,
    String userId,
  ) async {
    try {
      final data = _practiceSessionToSqlite(session);
      data['userId'] = userId;
      await _dbHelper.insert(DatabaseTables.tablePracticeSessions, data);
    } catch (e) {
      debugPrint('❌ Error saving practice session to cache: $e');
    }
  }

  // ==================== CACHE MANAGEMENT ====================

  /// Clear all cached data (call on logout)
  Future<void> clearCache() async {
    try {
      await _dbHelper.clearAllTables();
      debugPrint('✅ Cache cleared');
    } catch (e) {
      debugPrint('❌ Error clearing cache: $e');
    }
  }

  /// Update lesson in cache
  Future<void> updateLessonInCache(Lesson lesson) async {
    try {
      await _dbHelper.insert(
        DatabaseTables.tableLessons,
        _lessonToSqlite(lesson),
      );
    } catch (e) {
      debugPrint('❌ Error updating lesson in cache: $e');
    }
  }

  /// Update user progress in cache
  Future<void> updateUserProgressInCache(UserProgress progress) async {
    try {
      await _dbHelper.insert(
        DatabaseTables.tableUserProgress,
        _userProgressToSqlite(progress),
      );
    } catch (e) {
      debugPrint('❌ Error updating user progress in cache: $e');
    }
  }

  /// Update user preferences in cache
  Future<void> updateUserPreferencesInCache(UserPreferences prefs) async {
    try {
      await _dbHelper.insert(
        DatabaseTables.tableUserPreferences,
        _userPreferencesToSqlite(prefs),
      );
    } catch (e) {
      debugPrint('❌ Error updating user preferences in cache: $e');
    }
  }
}
