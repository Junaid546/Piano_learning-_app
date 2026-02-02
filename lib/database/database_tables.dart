/// SQL table schema definitions for SQLite database
/// Each table mirrors a Firestore collection/model
class DatabaseTables {
  // Database name and version
  static const String databaseName = 'pianoapp_cache.db';
  static const int databaseVersion = 3;

  // Table names
  static const String tableUsers = 'users';
  static const String tableLessons = 'lessons';
  static const String tableUserProgress = 'user_progress';
  static const String tableUserPreferences = 'user_preferences';
  static const String tablePracticeSessions = 'practice_sessions';

  /// Create users table
  /// Mirrors: UserModel from core/models/user_model.dart
  static const String createUsersTable =
      '''
    CREATE TABLE $tableUsers (
      id TEXT PRIMARY KEY,
      email TEXT NOT NULL,
      displayName TEXT NOT NULL,
      createdAt TEXT NOT NULL,
      lastLogin TEXT NOT NULL,
      profileImageUrl TEXT,
      bio TEXT,
      lastSyncedAt TEXT NOT NULL
    )
  ''';

  /// Create lessons table
  /// Mirrors: Lesson from features/lessons/models/lesson.dart
  static const String createLessonsTable =
      '''
    CREATE TABLE $tableLessons (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      category TEXT NOT NULL,
      description TEXT NOT NULL,
      difficulty TEXT NOT NULL,
      estimatedDuration INTEGER NOT NULL,
      order_num INTEGER NOT NULL,
      isCompleted INTEGER NOT NULL DEFAULT 0,
      isLocked INTEGER NOT NULL DEFAULT 0,
      objectives TEXT NOT NULL,
      notesToLearn TEXT NOT NULL,
      content TEXT NOT NULL,
      createdAt TEXT NOT NULL,
      lastSyncedAt TEXT NOT NULL
    )
  ''';

  /// Create index on lessons order for faster queries
  static const String createLessonsOrderIndex =
      '''
    CREATE INDEX idx_lessons_order ON $tableLessons(order_num)
  ''';

  /// Create user_progress table
  /// Mirrors: UserProgress from features/progress/models/user_progress.dart
  static const String createUserProgressTable =
      '''
    CREATE TABLE $tableUserProgress (
      userId TEXT PRIMARY KEY,
      completedLessonIds TEXT NOT NULL DEFAULT '[]',
      lessonsCompleted INTEGER NOT NULL DEFAULT 0,
      totalLessons INTEGER NOT NULL DEFAULT 0,
      practiceAttempts INTEGER NOT NULL DEFAULT 0,
      totalPracticeTime INTEGER NOT NULL DEFAULT 0,
      currentStreak INTEGER NOT NULL DEFAULT 0,
      longestStreak INTEGER NOT NULL DEFAULT 0,
      accuracy REAL NOT NULL DEFAULT 0.0,
      level INTEGER NOT NULL DEFAULT 1,
      xp INTEGER NOT NULL DEFAULT 0,
      achievementsUnlocked TEXT NOT NULL DEFAULT '[]',
      lastPracticeDate TEXT,
      practiceDates TEXT NOT NULL DEFAULT '{}',
      lastSyncedAt TEXT NOT NULL
    )
  ''';

  /// Create user_preferences table
  /// Mirrors: UserPreferences from features/profile/models/user_preferences.dart
  static const String createUserPreferencesTable =
      '''
    CREATE TABLE $tableUserPreferences (
      userId TEXT PRIMARY KEY,
      darkMode INTEGER NOT NULL DEFAULT 0,
      soundEffects INTEGER NOT NULL DEFAULT 1,
      hapticFeedback INTEGER NOT NULL DEFAULT 1,
      notifications INTEGER NOT NULL DEFAULT 1,
      dailyGoal INTEGER NOT NULL DEFAULT 30,
      reminderTime TEXT,
      difficulty TEXT NOT NULL DEFAULT 'medium',
      autoAdvanceLessons INTEGER NOT NULL DEFAULT 1,
      showKeyLabels INTEGER NOT NULL DEFAULT 1,
      language TEXT NOT NULL DEFAULT 'en',
      lastSyncedAt TEXT NOT NULL
    )
  ''';

  /// Create practice_sessions table
  /// Mirrors: PracticeSession from features/practice/models/practice_session.dart
  static const String createPracticeSessionsTable =
      '''
    CREATE TABLE $tablePracticeSessions (
      sessionId TEXT PRIMARY KEY,
      userId TEXT NOT NULL,
      startTime TEXT NOT NULL,
      endTime TEXT,
      totalAttempts INTEGER NOT NULL DEFAULT 0,
      correctAttempts INTEGER NOT NULL DEFAULT 0,
      score INTEGER NOT NULL DEFAULT 0,
      accuracy REAL NOT NULL DEFAULT 0.0,
      notesPlayed TEXT NOT NULL,
      difficulty TEXT NOT NULL,
      longestStreak INTEGER NOT NULL DEFAULT 0,
      lastSyncedAt TEXT NOT NULL
    )
  ''';

  /// Create index on practice sessions userId for faster queries
  static const String createPracticeSessionsUserIdIndex =
      '''
    CREATE INDEX idx_practice_sessions_userId ON $tablePracticeSessions(userId)
  ''';

  /// Get all create table statements
  static List<String> get createTableStatements => [
    createUsersTable,
    createLessonsTable,
    createLessonsOrderIndex,
    createUserProgressTable,
    createUserPreferencesTable,
    createPracticeSessionsTable,
    createPracticeSessionsUserIdIndex,
  ];

  /// Drop all tables (for migrations or reset)
  static List<String> get dropTableStatements => [
    'DROP TABLE IF EXISTS $tableUsers',
    'DROP TABLE IF EXISTS $tableLessons',
    'DROP TABLE IF EXISTS $tableUserProgress',
    'DROP TABLE IF EXISTS $tableUserPreferences',
    'DROP TABLE IF EXISTS $tablePracticeSessions',
  ];
}
