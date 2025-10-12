import '../dao/account_dao.dart';
import '../dao/child_account_dao.dart';
import '../dao/account_timeline_dao.dart';
import '../dao/account_tag_dao.dart';
import '../dao/account_audit_log_dao.dart';
import '../dao/account_blocking_state_dao.dart';
import '../dao/account_custom_field_dao.dart';
import '../dao/account_email_dao.dart';
import '../dao/account_invoice_payment_dao.dart';
import '../dao/account_payment_method_dao.dart';
import '../dao/account_payment_dao.dart';
import '../dao/account_invoices_dao.dart';
import '../dao/product_dao.dart';
import '../dao/plan_dao.dart';
import '../dao/payment_dao.dart';
import '../dao/tags_dao.dart';
import '../dao/user_dao.dart';
import '../dao/auth_token_dao.dart';
import '../dao/billing_record_dao.dart';
import '../dao/subscription_dao.dart';
import '../dao/sync_metadata_dao.dart';
import '../dao/tag_definitions_dao.dart';
import 'database_table_manager.dart';

/// Registers all database tables with their configurations
class DatabaseTableConfig {
  static void registerAllTables() {
    // Core tables
    DatabaseTableRegistry.registerTable(
      TableConfig(tableName: 'users', createTableSQL: UserDao.createTableSQL),
    );

    DatabaseTableRegistry.registerTable(
      TableConfig(
        tableName: 'auth_tokens',
        createTableSQL: AuthTokenDao.createTableSQL,
      ),
    );

    DatabaseTableRegistry.registerTable(
      TableConfig(
        tableName: 'billing_records',
        createTableSQL: BillingRecordDao.createTableSQL,
      ),
    );

    // Account-related tables
    DatabaseTableRegistry.registerTable(
      TableConfig(
        tableName: 'accounts',
        createTableSQL: AccountDao.createTableSQL,
      ),
    );

    DatabaseTableRegistry.registerTable(
      TableConfig(
        tableName: 'child_accounts',
        createTableSQL: ChildAccountDao.createTableSQL,
      ),
    );

    DatabaseTableRegistry.registerTable(
      TableConfig(
        tableName: 'account_timelines',
        createTableSQL: AccountTimelineDao.createTableSQL,
      ),
    );

    DatabaseTableRegistry.registerTable(
      TableConfig(
        tableName: 'account_tags',
        createTableSQL: AccountTagDao.createTableSQL,
      ),
    );

    DatabaseTableRegistry.registerTable(
      TableConfig(
        tableName: 'account_audit_logs',
        createTableSQL: AccountAuditLogDao.createTableSQL,
      ),
    );

    DatabaseTableRegistry.registerTable(
      TableConfig(
        tableName: 'account_blocking_states',
        createTableSQL: AccountBlockingStateDao.createTableSQL,
      ),
    );

    DatabaseTableRegistry.registerTable(
      TableConfig(
        tableName: 'account_custom_fields',
        createTableSQL: AccountCustomFieldDao.createTableSQL,
      ),
    );

    DatabaseTableRegistry.registerTable(
      TableConfig(
        tableName: 'account_emails',
        createTableSQL: AccountEmailDao.createTableSQL,
      ),
    );

    DatabaseTableRegistry.registerTable(
      TableConfig(
        tableName: 'account_invoice_payments',
        createTableSQL: AccountInvoicePaymentDao.createTableSQL,
      ),
    );

    DatabaseTableRegistry.registerTable(
      TableConfig(
        tableName: 'account_payment_methods',
        createTableSQL: AccountPaymentMethodDao.createTableSQL,
      ),
    );

    DatabaseTableRegistry.registerTable(
      TableConfig(
        tableName: 'account_payments',
        createTableSQL: AccountPaymentDao.createTableSQL,
      ),
    );

    DatabaseTableRegistry.registerTable(
      TableConfig(
        tableName: 'account_invoices',
        createTableSQL: AccountInvoicesDao.createTableSQL,
      ),
    );

    // Business tables
    DatabaseTableRegistry.registerTable(
      TableConfig(
        tableName: 'subscriptions',
        createTableSQL: SubscriptionDao.createTableSQL,
      ),
    );

    DatabaseTableRegistry.registerTable(
      TableConfig(
        tableName: 'products',
        createTableSQL: ProductDao.createTableSQL,
        createIndexesSQL: ProductDao.createIndexesSQL,
      ),
    );

    DatabaseTableRegistry.registerTable(
      TableConfig(tableName: 'plans', createTableSQL: PlanDao.createTableSQL),
    );

    DatabaseTableRegistry.registerTable(
      TableConfig(
        tableName: 'plan_features',
        createTableSQL: PlanDao.createPlanFeaturesTableSQL,
      ),
    );

    DatabaseTableRegistry.registerTable(
      TableConfig(
        tableName: 'payments',
        createTableSQL: PaymentDao.createTableSQL,
      ),
    );

    DatabaseTableRegistry.registerTable(
      TableConfig(
        tableName: 'payment_transactions',
        createTableSQL: PaymentDao.createTransactionsTableSQL,
      ),
    );

    DatabaseTableRegistry.registerTable(
      TableConfig(tableName: 'tags', createTableSQL: TagsDao.createTableSQL),
    );

    DatabaseTableRegistry.registerTable(
      TableConfig(
        tableName: 'tag_definitions',
        createTableSQL: TagDefinitionsDao.createTableSQL,
      ),
    );

    // System tables
    DatabaseTableRegistry.registerTable(
      TableConfig(
        tableName: 'sync_metadata',
        createTableSQL: SyncMetadataDao.createTableSQL,
      ),
    );
  }
}
