import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/receipt.dart';

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
      CREATE TABLE receipts (
        id $idType,
        receiptId $textType,
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
        UNIQUE(receiptId)
      )
    ''');
  }

  // Insert a receipt
  Future<int> insertReceipt(Receipt receipt) async {
    final db = await instance.database;
    return await db.insert(
      'receipts',
      receipt.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all receipts
  Future<List<Receipt>> getAllReceipts() async {
    final db = await instance.database;
    final result = await db.query(
      'receipts',
      orderBy: 'uploadedAt DESC',
    );
    return result.map((map) => Receipt.fromMap(map)).toList();
  }

  // Get receipt by ID
  Future<Receipt?> getReceipt(String receiptId) async {
    final db = await instance.database;
    final result = await db.query(
      'receipts',
      where: 'receiptId = ?',
      whereArgs: [receiptId],
    );
    if (result.isNotEmpty) {
      return Receipt.fromMap(result.first);
    }
    return null;
  }

  // Get receipts by user
  Future<List<Receipt>> getReceiptsByUser(String userId) async {
    final db = await instance.database;
    final result = await db.query(
      'receipts',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'uploadedAt DESC',
    );
    return result.map((map) => Receipt.fromMap(map)).toList();
  }

  // Get receipts by category
  Future<List<Receipt>> getReceiptsByCategory(String category) async {
    final db = await instance.database;
    final result = await db.query(
      'receipts',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'uploadedAt DESC',
    );
    return result.map((map) => Receipt.fromMap(map)).toList();
  }

  // Update a receipt
  Future<int> updateReceipt(Receipt receipt) async {
    final db = await instance.database;
    return await db.update(
      'receipts',
      receipt.toMap(),
      where: 'receiptId = ?',
      whereArgs: [receipt.receiptId],
    );
  }

  // Delete a receipt
  Future<int> deleteReceipt(String receiptId) async {
    final db = await instance.database;
    return await db.delete(
      'receipts',
      where: 'receiptId = ?',
      whereArgs: [receiptId],
    );
  }

  // Clear all receipts
  Future<int> clearAllReceipts() async {
    final db = await instance.database;
    return await db.delete('receipts');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
