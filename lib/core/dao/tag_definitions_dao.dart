import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../features/tag_definitions/data/models/tag_definition_model.dart';

class TagDefinitionsDao {
  static const String tableName = 'tag_definitions';

  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnDescription = 'description';
  static const String columnIsControlTag = 'is_control_tag';
  static const String columnApplicableObjectTypes = 'applicable_object_types';
  static const String columnAuditLogs = 'audit_logs';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
  static const String columnSyncStatus = 'sync_status';

  static const String createTableSQL =
      '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnName TEXT NOT NULL,
      $columnDescription TEXT,
      $columnIsControlTag INTEGER NOT NULL DEFAULT 0,
      $columnApplicableObjectTypes TEXT NOT NULL,
      $columnAuditLogs TEXT,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL,
      $columnSyncStatus TEXT NOT NULL DEFAULT 'synced'
    )
  ''';

  static Map<String, dynamic> toMap(TagDefinitionModel tagDefinition) {
    return {
      columnId: tagDefinition.id,
      columnName: tagDefinition.name,
      columnDescription: tagDefinition.description,
      columnIsControlTag: tagDefinition.isControlTag ? 1 : 0,
      columnApplicableObjectTypes: tagDefinition.applicableObjectTypes.join(
        ',',
      ),
      columnAuditLogs: tagDefinition.auditLogs
          .map((log) => log['id']?.toString() ?? '')
          .join(','),
      columnCreatedAt:
          tagDefinition.createdAt ?? DateTime.now().toIso8601String(),
      columnUpdatedAt:
          tagDefinition.updatedAt ?? DateTime.now().toIso8601String(),
      columnSyncStatus: 'synced',
    };
  }

  static TagDefinitionModel fromMap(Map<String, dynamic> map) {
    return TagDefinitionModel(
      id: map[columnId] as String,
      name: map[columnName] as String,
      description: map[columnDescription] as String? ?? '',
      isControlTag: (map[columnIsControlTag] as int) == 1,
      applicableObjectTypes: (map[columnApplicableObjectTypes] as String)
          .split(',')
          .where((type) => type.isNotEmpty)
          .toList(),
      auditLogs:
          (map[columnAuditLogs] as String?)
              ?.split(',')
              .where((id) => id.isNotEmpty)
              .map((id) => {'id': id})
              .toList() ??
          [],
      createdAt: map[columnCreatedAt] as String?,
      updatedAt: map[columnUpdatedAt] as String?,
    );
  }

  static Future<void> insertTagDefinition(
    Database db,
    TagDefinitionModel tagDefinition,
  ) async {
    await db.insert(
      tableName,
      toMap(tagDefinition),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> insertTagDefinitions(
    Database db,
    List<TagDefinitionModel> tagDefinitions,
  ) async {
    final batch = db.batch();
    for (final tagDefinition in tagDefinitions) {
      batch.insert(
        tableName,
        toMap(tagDefinition),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
  }

  static Future<List<TagDefinitionModel>> getAllTagDefinitions(
    Database db,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: '$columnName ASC',
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  static Future<TagDefinitionModel?> getTagDefinitionById(
    Database db,
    String id,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return fromMap(maps.first);
    }
    return null;
  }

  static Future<List<TagDefinitionModel>> searchTagDefinitions(
    Database db,
    String query,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnName LIKE ? OR $columnDescription LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: '$columnName ASC',
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  static Future<void> updateTagDefinition(
    Database db,
    TagDefinitionModel tagDefinition,
  ) async {
    await db.update(
      tableName,
      toMap(tagDefinition),
      where: '$columnId = ?',
      whereArgs: [tagDefinition.id],
    );
  }

  static Future<void> deleteTagDefinition(Database db, String id) async {
    await db.delete(tableName, where: '$columnId = ?', whereArgs: [id]);
  }

  static Future<void> deleteTagDefinitions(
    Database db,
    List<String> ids,
  ) async {
    if (ids.isEmpty) return;
    final placeholders = ids.map((_) => '?').join(',');
    await db.delete(
      tableName,
      where: '$columnId IN ($placeholders)',
      whereArgs: ids,
    );
  }

  static Future<void> clearAllTagDefinitions(Database db) async {
    await db.delete(tableName);
  }

  static Future<int> getTagDefinitionsCount(Database db) async {
    final result = await db.rawQuery('SELECT COUNT(*) FROM $tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  static Future<List<TagDefinitionModel>> getTagDefinitionsBySyncStatus(
    Database db,
    String syncStatus,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnSyncStatus = ?',
      whereArgs: [syncStatus],
      orderBy: '$columnName ASC',
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  static Future<void> updateSyncStatus(
    Database db,
    String id,
    String syncStatus,
  ) async {
    await db.update(
      tableName,
      {columnSyncStatus: syncStatus},
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  static Stream<List<TagDefinitionModel>> watchTagDefinitions(Database db) {
    // For now, return an empty stream since we're not using reactive updates
    // In a real implementation, you might want to use a StreamController
    // with manual triggers when data changes
    return Stream.empty();
  }

  static Stream<List<TagDefinitionModel>> watchTagDefinitionsBySearchQuery(
    Database db,
    String query,
  ) {
    // For now, return an empty stream since we're not using reactive updates
    return Stream.empty();
  }
}
