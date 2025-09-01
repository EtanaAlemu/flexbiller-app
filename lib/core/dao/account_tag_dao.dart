import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../features/accounts/data/models/account_tag_model.dart';

/// Data Access Object for AccountTagModel
class AccountTagDao {
  // Table name
  static const String tableName = 'account_tags';

  // Column names
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnDescription = 'description';
  static const String columnColor = 'color';
  static const String columnIcon = 'icon';
  static const String columnCreatedAt = 'createdAt';
  static const String columnUpdatedAt = 'updatedAt';
  static const String columnCreatedBy = 'createdBy';
  static const String columnIsActive = 'isActive';
  static const String columnSyncStatus = 'syncStatus';

  // SQL to create the table
  static String get createTableSQL =>
      '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnName TEXT NOT NULL,
      $columnDescription TEXT,
      $columnColor TEXT,
      $columnIcon TEXT,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL,
      $columnCreatedBy TEXT NOT NULL,
      $columnIsActive INTEGER NOT NULL,
      $columnSyncStatus TEXT NOT NULL
    )
  ''';

  // Convert AccountTagModel to database map
  static Map<String, dynamic> toMap(Map<String, dynamic> model) {
    return {
      columnId: model['id'],
      columnName: model['name'],
      columnDescription: model['description'],
      columnColor: model['color'],
      columnIcon: model['icon'],
      columnCreatedAt: model['createdAt']?.toString(),
      columnUpdatedAt: model['updatedAt']?.toString(),
      columnCreatedBy: model['createdBy'],
      columnIsActive: model['isActive'] == true ? 1 : 0,
      columnSyncStatus: model['syncStatus'] ?? 'synced',
    };
  }

  // Convert database map to AccountTagModel
  static Map<String, dynamic>? fromMap(Map<String, dynamic> map) {
    try {
      return {
        'id': map[columnId],
        'name': map[columnName],
        'description': map[columnDescription],
        'color': map[columnColor],
        'icon': map[columnIcon],
        'createdAt': DateTime.tryParse(map[columnCreatedAt] ?? ''),
        'updatedAt': DateTime.tryParse(map[columnUpdatedAt] ?? ''),
        'createdBy': map[columnCreatedBy],
        'isActive': map[columnIsActive] == 1,
        'syncStatus': map[columnSyncStatus],
      };
    } catch (e) {
      return null;
    }
  }

  // Helper methods for common operations - using dynamic to handle both Database and Transaction
  static Future<void> insertTag(
    dynamic db,
    Map<String, dynamic> tagData,
  ) async {
    await db.insert(tableName, toMap(tagData));
  }

  static Future<void> updateTag(
    dynamic db,
    Map<String, dynamic> tagData,
  ) async {
    await db.update(
      tableName,
      toMap(tagData),
      where: '$columnId = ?',
      whereArgs: [tagData['id']],
    );
  }

  static Future<void> deleteTag(dynamic db, String tagId) async {
    await db.delete(tableName, where: '$columnId = ?', whereArgs: [tagId]);
  }

  static Future<Map<String, dynamic>?> getTagById(
    dynamic db,
    String tagId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnId = ?',
      whereArgs: [tagId],
    );

    if (maps.isNotEmpty) {
      return fromMap(maps.first);
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> getAllTags(dynamic db) async {
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return maps
        .map((map) => fromMap(map))
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getTagsByAccount(
    dynamic db,
    String accountId,
  ) async {
    // This would need a join table for account-tag relationships
    // For now, return all tags
    return getAllTags(db);
  }
}
