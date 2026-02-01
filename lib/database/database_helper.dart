import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_tables.dart';

/// DatabaseHelper - Singleton class for managing SQLite database
/// Provides CRUD operations and database lifecycle management
class DatabaseHelper {
  // Singleton instance
  static DatabaseHelper? _instance;
  static Database? _database;

  // Private constructor
  DatabaseHelper._();

  /// Get singleton instance
  static DatabaseHelper getInstance() {
    _instance ??= DatabaseHelper._();
    return _instance!;
  }

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  /// Initialize database and create tables
  Future<Database> initDatabase() async {
    // Get database path
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, DatabaseTables.databaseName);

    // Open database
    return await openDatabase(
      path,
      version: DatabaseTables.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create tables on first database creation
  Future<void> _onCreate(Database db, int version) async {
    // Execute all create table statements
    for (final statement in DatabaseTables.createTableStatements) {
      await db.execute(statement);
    }
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migration logic goes here
    // For now, we'll recreate tables (data loss acceptable for cache)
    if (oldVersion < newVersion) {
      for (final statement in DatabaseTables.dropTableStatements) {
        await db.execute(statement);
      }
      for (final statement in DatabaseTables.createTableStatements) {
        await db.execute(statement);
      }
    }
  }

  // ==================== GENERIC CRUD OPERATIONS ====================

  /// Insert a record into a table
  /// Returns the row ID of the inserted record
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insert multiple records in a batch
  Future<void> insertBatch(
    String table,
    List<Map<String, dynamic>> dataList,
  ) async {
    final db = await database;
    final batch = db.batch();
    for (final data in dataList) {
      batch.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  /// Update a record in a table
  /// Returns the number of rows affected
  Future<int> update(
    String table,
    Map<String, dynamic> data,
    String whereClause,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.update(
      table,
      data,
      where: whereClause,
      whereArgs: whereArgs,
    );
  }

  /// Delete a record from a table
  /// Returns the number of rows affected
  Future<int> delete(
    String table,
    String whereClause,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.delete(table, where: whereClause, whereArgs: whereArgs);
  }

  /// Query records from a table
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  /// Query a single record from a table
  Future<Map<String, dynamic>?> queryOne(
    String table,
    String whereClause,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    final results = await db.query(
      table,
      where: whereClause,
      whereArgs: whereArgs,
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Execute a raw SQL query
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  /// Execute a raw SQL statement
  Future<void> rawExecute(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    await db.execute(sql, arguments);
  }

  // ==================== TABLE-SPECIFIC OPERATIONS ====================

  /// Clear all data from a specific table
  Future<void> clearTable(String table) async {
    final db = await database;
    await db.delete(table);
  }

  /// Clear all tables (useful for logout)
  Future<void> clearAllTables() async {
    final db = await database;
    final batch = db.batch();
    batch.delete(DatabaseTables.tableUsers);
    batch.delete(DatabaseTables.tableLessons);
    batch.delete(DatabaseTables.tableUserProgress);
    batch.delete(DatabaseTables.tableUserPreferences);
    batch.delete(DatabaseTables.tablePracticeSessions);
    await batch.commit(noResult: true);
  }

  /// Get the count of records in a table
  Future<int> getCount(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    final result = await db.query(
      table,
      columns: ['COUNT(*) as count'],
      where: where,
      whereArgs: whereArgs,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Check if a record exists
  Future<bool> exists(
    String table,
    String whereClause,
    List<dynamic> whereArgs,
  ) async {
    final count = await getCount(
      table,
      where: whereClause,
      whereArgs: whereArgs,
    );
    return count > 0;
  }

  /// Close database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  // ==================== HELPER METHODS ====================

  /// Add lastSyncedAt timestamp to data
  Map<String, dynamic> addSyncTimestamp(Map<String, dynamic> data) {
    return {...data, 'lastSyncedAt': DateTime.now().toIso8601String()};
  }

  /// Convert boolean to SQLite integer (0 or 1)
  int boolToInt(bool value) => value ? 1 : 0;

  /// Convert SQLite integer to boolean
  bool intToBool(int value) => value == 1;
}
