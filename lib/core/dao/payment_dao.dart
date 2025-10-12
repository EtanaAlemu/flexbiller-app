class PaymentDao {
  static const String tableName = 'payments';
  static const String transactionsTableName = 'payment_transactions';

  static const String createTableSQL =
      '''
    CREATE TABLE $tableName (
      account_id TEXT NOT NULL,
      payment_id TEXT PRIMARY KEY,
      payment_number TEXT NOT NULL,
      payment_external_key TEXT NOT NULL,
      auth_amount REAL NOT NULL DEFAULT 0,
      captured_amount REAL NOT NULL DEFAULT 0,
      purchased_amount REAL NOT NULL DEFAULT 0,
      refunded_amount REAL NOT NULL DEFAULT 0,
      credited_amount REAL NOT NULL DEFAULT 0,
      currency TEXT NOT NULL,
      payment_method_id TEXT NOT NULL,
      payment_attempts TEXT,
      audit_logs TEXT,
      created_at TEXT NOT NULL
    )
  ''';

  static const String createTransactionsTableSQL =
      '''
    CREATE TABLE $transactionsTableName (
      transaction_id TEXT PRIMARY KEY,
      transaction_external_key TEXT NOT NULL,
      payment_id TEXT NOT NULL,
      payment_external_key TEXT NOT NULL,
      transaction_type TEXT NOT NULL,
      amount REAL NOT NULL,
      currency TEXT NOT NULL,
      effective_date TEXT NOT NULL,
      processed_amount REAL NOT NULL,
      processed_currency TEXT NOT NULL,
      status TEXT NOT NULL,
      gateway_error_code TEXT,
      gateway_error_msg TEXT,
      first_payment_reference_id TEXT,
      second_payment_reference_id TEXT,
      properties TEXT,
      audit_logs TEXT,
      FOREIGN KEY (payment_id) REFERENCES $tableName (payment_id) ON DELETE CASCADE
    )
  ''';
}
