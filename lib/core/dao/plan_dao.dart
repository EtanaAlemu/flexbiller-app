class PlanDao {
  static const String tableName = 'plans';
  static const String featuresTableName = 'plan_features';

  static const String createTableSQL =
      '''
    CREATE TABLE $tableName (
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
  ''';

  static const String createPlanFeaturesTableSQL =
      '''
    CREATE TABLE $featuresTableName (
      id TEXT PRIMARY KEY,
      plan_id TEXT NOT NULL,
      feature_name TEXT NOT NULL,
      feature_value TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (plan_id) REFERENCES $tableName (id) ON DELETE CASCADE
    )
  ''';
}
