import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:injectable/injectable.dart';
import '../constants/app_constants.dart';

@injectable
class DatabaseService {
  static Database? _database;
  static const String _encryptionKey = 'your-secure-encryption-key-here';
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.databaseName);
    
    // Check if database exists
    final exists = await databaseExists(path);
    
    if (!exists) {
      // Create database
      return await openDatabase(
        path,
        version: AppConstants.databaseVersion,
        onCreate: _onCreate,
        password: _encryptionKey,
      );
    } else {
      // Open existing database
      return await openDatabase(
        path,
        version: AppConstants.databaseVersion,
        onUpgrade: _onUpgrade,
        password: _encryptionKey,
      );
    }
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        name TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    
    // Create auth_tokens table
    await db.execute('''
      CREATE TABLE auth_tokens (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        access_token TEXT NOT NULL,
        refresh_token TEXT NOT NULL,
        expires_at TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
    
    // Create billing_records table
    await db.execute('''
      CREATE TABLE billing_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        description TEXT,
        due_date TEXT,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns or tables for version 2
      // await db.execute('ALTER TABLE users ADD COLUMN phone TEXT');
    }
  }
  
  // Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
  
  // Delete database
  Future<void> deleteDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
  
  // Helper method to execute raw SQL
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<Object>? arguments]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }
  
  // Helper method to execute raw SQL without returning results
  Future<void> rawExecute(String sql, [List<Object>? arguments]) async {
    final db = await database;
    await db.execute(sql, arguments);
  }
}
