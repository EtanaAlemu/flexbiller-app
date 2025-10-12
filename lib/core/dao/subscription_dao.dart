class SubscriptionDao {
  static const String tableName = 'subscriptions';

  static const String createTableSQL =
      '''
    CREATE TABLE $tableName (
      subscription_id TEXT PRIMARY KEY,
      account_id TEXT NOT NULL,
      bundle_id TEXT NOT NULL,
      bundle_external_key TEXT NOT NULL,
      external_key TEXT NOT NULL,
      start_date TEXT NOT NULL,
      product_name TEXT NOT NULL,
      product_category TEXT NOT NULL,
      billing_period TEXT NOT NULL,
      phase_type TEXT NOT NULL,
      price_list TEXT NOT NULL,
      plan_name TEXT NOT NULL,
      state TEXT NOT NULL,
      source_type TEXT NOT NULL,
      cancelled_date TEXT,
      charged_through_date TEXT NOT NULL,
      billing_start_date TEXT NOT NULL,
      billing_end_date TEXT,
      bill_cycle_day_local INTEGER NOT NULL,
      quantity INTEGER NOT NULL,
      events TEXT NOT NULL,
      price_overrides TEXT,
      prices TEXT NOT NULL,
      audit_logs TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''';
}
