import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:logger/logger.dart';

class PlanDao {
  static final Logger _logger = Logger();

  static Future<void> createTable(Database db) async {
    try {
      _logger.d('Creating plans table...');

      await db.execute('''
        CREATE TABLE plans (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          price REAL NOT NULL,
          billing_cycle TEXT NOT NULL,
          trial_days INTEGER NOT NULL,
          is_active INTEGER NOT NULL DEFAULT 1,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      _logger.d('Plans table created successfully');
    } catch (e) {
      _logger.e('Error creating plans table: $e');
      rethrow;
    }
  }

  static Future<void> createPlanFeaturesTable(Database db) async {
    try {
      _logger.d('Creating plan_features table...');

      await db.execute('''
        CREATE TABLE plan_features (
          id TEXT PRIMARY KEY,
          plan_id TEXT NOT NULL,
          feature_name TEXT NOT NULL,
          feature_value TEXT NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY (plan_id) REFERENCES plans (id) ON DELETE CASCADE
        )
      ''');

      _logger.d('Plan features table created successfully');
    } catch (e) {
      _logger.e('Error creating plan_features table: $e');
      rethrow;
    }
  }
}

