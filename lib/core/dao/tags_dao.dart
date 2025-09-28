import 'package:sqflite_sqlcipher/sqflite.dart';

/// Data Access Object for TagModel
class TagsDao {
  // Table name
  static const String tableName = 'tags';

  // Column names
  static const String columnTagId = 'tagId';
  static const String columnObjectType = 'objectType';
  static const String columnObjectId = 'objectId';
  static const String columnTagDefinitionId = 'tagDefinitionId';
  static const String columnTagDefinitionName = 'tagDefinitionName';
  static const String columnAuditLogs = 'auditLogs';
  static const String columnCreatedAt = 'createdAt';
  static const String columnUpdatedAt = 'updatedAt';
  static const String columnSyncStatus = 'syncStatus';

  // SQL to create the table
  static String get createTableSQL =>
      '''
    CREATE TABLE $tableName (
      $columnTagId TEXT PRIMARY KEY,
      $columnObjectType TEXT NOT NULL,
      $columnObjectId TEXT NOT NULL,
      $columnTagDefinitionId TEXT NOT NULL,
      $columnTagDefinitionName TEXT NOT NULL,
      $columnAuditLogs TEXT,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL,
      $columnSyncStatus TEXT NOT NULL DEFAULT 'synced'
    )
  ''';

  // Convert TagModel to database map
  static Map<String, dynamic> toMap(Map<String, dynamic> model) {
    return {
      columnTagId: model['tagId'],
      columnObjectType: model['objectType'],
      columnObjectId: model['objectId'],
      columnTagDefinitionId: model['tagDefinitionId'],
      columnTagDefinitionName: model['tagDefinitionName'],
      columnAuditLogs: model['auditLogs'] != null
          ? (model['auditLogs'] as List<Map<String, dynamic>>)
                .map((e) => e['id']?.toString() ?? e.toString())
                .join(',')
          : null,
      columnCreatedAt:
          model['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      columnUpdatedAt:
          model['updatedAt']?.toString() ?? DateTime.now().toIso8601String(),
      columnSyncStatus: model['syncStatus'] ?? 'synced',
    };
  }

  // Convert database map to TagModel
  static Map<String, dynamic> fromMap(Map<String, dynamic> map) {
    return {
      'tagId': map[columnTagId],
      'objectType': map[columnObjectType],
      'objectId': map[columnObjectId],
      'tagDefinitionId': map[columnTagDefinitionId],
      'tagDefinitionName': map[columnTagDefinitionName],
      'auditLogs': map[columnAuditLogs] != null
          ? (map[columnAuditLogs] as String)
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .map((e) => <String, dynamic>{'id': e})
                .toList()
          : <Map<String, dynamic>>[],
      'createdAt': map[columnCreatedAt],
      'updatedAt': map[columnUpdatedAt],
      'syncStatus': map[columnSyncStatus] ?? 'synced',
    };
  }

  // Insert a tag
  static Future<void> insertTag(Database db, Map<String, dynamic> tag) async {
    await db.insert(
      tableName,
      toMap(tag),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Insert multiple tags
  static Future<void> insertTags(
    Database db,
    List<Map<String, dynamic>> tags,
  ) async {
    final batch = db.batch();
    for (final tag in tags) {
      batch.insert(
        tableName,
        toMap(tag),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
  }

  // Get all tags
  static Future<List<Map<String, dynamic>>> getAllTags(Database db) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: '$columnCreatedAt DESC',
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  // Get tag by ID
  static Future<Map<String, dynamic>?> getTagById(
    Database db,
    String tagId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnTagId = ?',
      whereArgs: [tagId],
    );
    if (maps.isNotEmpty) {
      return fromMap(maps.first);
    }
    return null;
  }

  // Search tags by tag definition name
  static Future<List<Map<String, dynamic>>> searchTags(
    Database db,
    String tagDefinitionName, {
    int offset = 0,
    int limit = 100,
  }) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnTagDefinitionName LIKE ?',
      whereArgs: ['%$tagDefinitionName%'],
      orderBy: '$columnCreatedAt DESC',
      limit: limit,
      offset: offset,
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  // Update a tag
  static Future<void> updateTag(Database db, Map<String, dynamic> tag) async {
    await db.update(
      tableName,
      toMap(tag),
      where: '$columnTagId = ?',
      whereArgs: [tag['tagId']],
    );
  }

  // Delete a tag
  static Future<void> deleteTag(Database db, String tagId) async {
    await db.delete(tableName, where: '$columnTagId = ?', whereArgs: [tagId]);
  }

  // Delete multiple tags
  static Future<void> deleteTags(Database db, List<String> tagIds) async {
    final batch = db.batch();
    for (final tagId in tagIds) {
      batch.delete(tableName, where: '$columnTagId = ?', whereArgs: [tagId]);
    }
    await batch.commit();
  }

  // Clear all tags
  static Future<void> clearAllTags(Database db) async {
    await db.delete(tableName);
  }

  // Get tags count
  static Future<int> getTagsCount(Database db) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName',
    );
    return result.first['count'] as int;
  }

  // Get tags by sync status
  static Future<List<Map<String, dynamic>>> getTagsBySyncStatus(
    Database db,
    String syncStatus,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnSyncStatus = ?',
      whereArgs: [syncStatus],
      orderBy: '$columnCreatedAt DESC',
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  // Update sync status for multiple tags
  static Future<void> updateSyncStatus(
    Database db,
    List<String> tagIds,
    String syncStatus,
  ) async {
    final batch = db.batch();
    for (final tagId in tagIds) {
      batch.update(
        tableName,
        {
          columnSyncStatus: syncStatus,
          columnUpdatedAt: DateTime.now().toIso8601String(),
        },
        where: '$columnTagId = ?',
        whereArgs: [tagId],
      );
    }
    await batch.commit();
  }

  // Watch all tags (for reactive updates)
  static Stream<List<Map<String, dynamic>>> watchTags(Database db) {
    return db
        .query(tableName, orderBy: '$columnCreatedAt DESC')
        .asStream()
        .map((maps) => maps.map((map) => fromMap(map)).toList());
  }

  // Watch tags by query
  static Stream<List<Map<String, dynamic>>> watchTagsByQuery(
    Database db,
    String? searchQuery,
  ) {
    if (searchQuery == null || searchQuery.isEmpty) {
      return watchTags(db);
    }

    return db
        .query(
          tableName,
          where: '$columnTagDefinitionName LIKE ?',
          whereArgs: ['%$searchQuery%'],
          orderBy: '$columnCreatedAt DESC',
        )
        .asStream()
        .map((maps) => maps.map((map) => fromMap(map)).toList());
  }
}
