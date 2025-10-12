class SyncMetadataDao {
  static const String tableName = 'sync_metadata';

  static const String createTableSQL =
      '''
    CREATE TABLE $tableName (
      table_name TEXT PRIMARY KEY,
      last_sync TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''';
}
