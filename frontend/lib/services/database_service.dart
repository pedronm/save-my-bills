import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/screenshot.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('savemybills.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';
    const realType = 'REAL';

    await db.execute('''
      CREATE TABLE screenshots (
        id $idType,
        screenshotId $textType,
        filename $textType,
        contentType $textTypeNullable,
        fileSize $realType,
        driveFileId $textType,
        driveFileUrl $textTypeNullable,
        uploadedAt $textType,
        lastAccessedAt $textTypeNullable,
        userId $textTypeNullable,
        category $textTypeNullable,
        amount $realType,
        currency $textTypeNullable,
        billDate $textTypeNullable,
        vendor $textTypeNullable,
        tags $textTypeNullable,
        UNIQUE(screenshotId)
      )
    ''');
  }

  // Insert a screenshot
  Future<int> insertScreenshot(Screenshot screenshot) async {
    final db = await instance.database;
    return await db.insert(
      'screenshots',
      screenshot.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all screenshots
  Future<List<Screenshot>> getAllScreenshots() async {
    final db = await instance.database;
    final result = await db.query(
      'screenshots',
      orderBy: 'uploadedAt DESC',
    );
    return result.map((map) => Screenshot.fromMap(map)).toList();
  }

  // Get screenshot by ID
  Future<Screenshot?> getScreenshot(String screenshotId) async {
    final db = await instance.database;
    final result = await db.query(
      'screenshots',
      where: 'screenshotId = ?',
      whereArgs: [screenshotId],
    );
    if (result.isNotEmpty) {
      return Screenshot.fromMap(result.first);
    }
    return null;
  }

  // Get screenshots by user
  Future<List<Screenshot>> getScreenshotsByUser(String userId) async {
    final db = await instance.database;
    final result = await db.query(
      'screenshots',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'uploadedAt DESC',
    );
    return result.map((map) => Screenshot.fromMap(map)).toList();
  }

  // Get screenshots by category
  Future<List<Screenshot>> getScreenshotsByCategory(String category) async {
    final db = await instance.database;
    final result = await db.query(
      'screenshots',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'uploadedAt DESC',
    );
    return result.map((map) => Screenshot.fromMap(map)).toList();
  }

  // Update a screenshot
  Future<int> updateScreenshot(Screenshot screenshot) async {
    final db = await instance.database;
    return await db.update(
      'screenshots',
      screenshot.toMap(),
      where: 'screenshotId = ?',
      whereArgs: [screenshot.screenshotId],
    );
  }

  // Delete a screenshot
  Future<int> deleteScreenshot(String screenshotId) async {
    final db = await instance.database;
    return await db.delete(
      'screenshots',
      where: 'screenshotId = ?',
      whereArgs: [screenshotId],
    );
  }

  // Clear all screenshots
  Future<int> clearAllScreenshots() async {
    final db = await instance.database;
    return await db.delete('screenshots');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
