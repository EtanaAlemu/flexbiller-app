import 'dart:convert';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../features/accounts/data/models/account_invoice_model.dart';

class AccountInvoicesDao {
  static const String tableName = 'account_invoices';

  static const String createTableSQL =
      '''
    CREATE TABLE $tableName (
      invoice_id TEXT PRIMARY KEY,
      invoice_number TEXT NOT NULL,
      account_id TEXT NOT NULL,
      amount REAL NOT NULL,
      currency TEXT NOT NULL,
      status TEXT NOT NULL,
      balance REAL NOT NULL,
      credit_adj REAL NOT NULL,
      refund_adj REAL NOT NULL,
      invoice_date TEXT NOT NULL,
      target_date TEXT NOT NULL,
      bundle_keys TEXT,
      credits TEXT,
      items TEXT NOT NULL,
      tracking_ids TEXT NOT NULL,
      is_parent_invoice INTEGER NOT NULL,
      parent_invoice_id TEXT,
      parent_account_id TEXT,
      audit_logs TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''';

  static Map<String, dynamic> toMap(AccountInvoiceModel invoice) {
    final now = DateTime.now().toIso8601String();
    return {
      'invoice_id': invoice.invoiceId,
      'invoice_number': invoice.invoiceNumber,
      'account_id': invoice.accountId,
      'amount': invoice.amount,
      'currency': invoice.currency,
      'status': invoice.status,
      'balance': invoice.balance,
      'credit_adj': invoice.creditAdj,
      'refund_adj': invoice.refundAdj,
      'invoice_date': invoice.invoiceDate,
      'target_date': invoice.targetDate,
      'bundle_keys': invoice.bundleKeys?.join(','),
      'credits': invoice.credits != null ? jsonEncode(invoice.credits) : null,
      'items': jsonEncode(invoice.items),
      'tracking_ids': invoice.trackingIds.join(','),
      'is_parent_invoice': invoice.isParentInvoice ? 1 : 0,
      'parent_invoice_id': invoice.parentInvoiceId,
      'parent_account_id': invoice.parentAccountId,
      'audit_logs': jsonEncode(invoice.auditLogs),
      'created_at': now,
      'updated_at': now,
    };
  }

  static AccountInvoiceModel fromMap(Map<String, dynamic> map) {
    return AccountInvoiceModel(
      invoiceId: map['invoice_id'] as String,
      invoiceNumber: map['invoice_number'] as String,
      accountId: map['account_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String,
      status: map['status'] as String,
      balance: (map['balance'] as num).toDouble(),
      creditAdj: (map['credit_adj'] as num).toDouble(),
      refundAdj: (map['refund_adj'] as num).toDouble(),
      invoiceDate: map['invoice_date'] as String,
      targetDate: map['target_date'] as String,
      bundleKeys: map['bundle_keys']?.toString().split(',') ?? [],
      credits: map['credits'] != null
          ? jsonDecode(map['credits'] as String) as List<Map<String, dynamic>>
          : null,
      items: (jsonDecode(map['items'] as String) as List<dynamic>)
          .cast<Map<String, dynamic>>(),
      trackingIds: map['tracking_ids'].toString().split(','),
      isParentInvoice: (map['is_parent_invoice'] as int) == 1,
      parentInvoiceId: map['parent_invoice_id'] as String?,
      parentAccountId: map['parent_account_id'] as String?,
      auditLogs: (jsonDecode(map['audit_logs'] as String) as List<dynamic>)
          .cast<Map<String, dynamic>>(),
    );
  }

  // Insert or update an invoice
  static Future<void> insertOrUpdate(
    dynamic db,
    AccountInvoiceModel invoice,
  ) async {
    final map = toMap(invoice);
    await db.insert(
      tableName,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Insert multiple invoices
  static Future<void> insertMultiple(
    dynamic db,
    List<AccountInvoiceModel> invoices,
  ) async {
    await db.transaction((txn) async {
      for (final invoice in invoices) {
        await insertOrUpdate(txn, invoice);
      }
    });
  }

  // Get all invoices for a specific account
  static Future<List<AccountInvoiceModel>> getByAccountId(
    dynamic db,
    String accountId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'account_id = ?',
      whereArgs: [accountId],
      orderBy: 'invoice_date DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get a specific invoice by ID
  static Future<AccountInvoiceModel?> getById(
    dynamic db,
    String invoiceId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'invoice_id = ?',
      whereArgs: [invoiceId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return fromMap(maps.first);
    }
    return null;
  }

  // Get invoices by status
  static Future<List<AccountInvoiceModel>> getByStatus(
    dynamic db,
    String accountId,
    String status,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'account_id = ? AND status = ?',
      whereArgs: [accountId, status],
      orderBy: 'invoice_date DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get invoices by date range
  static Future<List<AccountInvoiceModel>> getByDateRange(
    dynamic db,
    String accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'account_id = ? AND invoice_date BETWEEN ? AND ?',
      whereArgs: [
        accountId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'invoice_date DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get invoices by amount range
  static Future<List<AccountInvoiceModel>> getByAmountRange(
    dynamic db,
    String accountId,
    double minAmount,
    double maxAmount,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'account_id = ? AND amount BETWEEN ? AND ?',
      whereArgs: [accountId, minAmount, maxAmount],
      orderBy: 'amount DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get invoices by currency
  static Future<List<AccountInvoiceModel>> getByCurrency(
    dynamic db,
    String accountId,
    String currency,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'account_id = ? AND currency = ?',
      whereArgs: [accountId, currency],
      orderBy: 'invoice_date DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get invoices with pagination
  static Future<List<AccountInvoiceModel>> getWithPagination(
    dynamic db,
    String accountId,
    int page,
    int pageSize,
  ) async {
    final offset = page * pageSize;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'account_id = ?',
      whereArgs: [accountId],
      orderBy: 'invoice_date DESC',
      limit: pageSize,
      offset: offset,
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get all invoices
  static Future<List<AccountInvoiceModel>> getAll(dynamic db) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'invoice_date DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Update an invoice
  static Future<int> update(dynamic db, AccountInvoiceModel invoice) async {
    final map = toMap(invoice);
    map['updated_at'] = DateTime.now().toIso8601String();

    return await db.update(
      tableName,
      map,
      where: 'invoice_id = ?',
      whereArgs: [invoice.invoiceId],
    );
  }

  // Delete an invoice
  static Future<int> delete(dynamic db, String invoiceId) async {
    return await db.delete(
      tableName,
      where: 'invoice_id = ?',
      whereArgs: [invoiceId],
    );
  }

  // Delete invoices by account ID
  static Future<int> deleteByAccountId(dynamic db, String accountId) async {
    return await db.delete(
      tableName,
      where: 'account_id = ?',
      whereArgs: [accountId],
    );
  }

  // Delete all invoices
  static Future<int> deleteAll(dynamic db) async {
    return await db.delete(tableName);
  }

  // Get count of invoices for a specific account
  static Future<int> getCountByAccountId(dynamic db, String accountId) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE account_id = ?',
      [accountId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get count by status for a specific account
  static Future<int> getCountByStatus(
    dynamic db,
    String accountId,
    String status,
  ) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE account_id = ? AND status = ?',
      [accountId, status],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get total count of all invoices
  static Future<int> getTotalCount(dynamic db) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get total amount by status for a specific account
  static Future<double> getTotalAmountByStatus(
    dynamic db,
    String accountId,
    String status,
  ) async {
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM $tableName WHERE account_id = ? AND status = ?',
      [accountId, status],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Get total amount for a specific account
  static Future<double> getTotalAmountByAccountId(
    dynamic db,
    String accountId,
  ) async {
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM $tableName WHERE account_id = ?',
      [accountId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Get total balance for a specific account
  static Future<double> getTotalBalanceByAccountId(
    dynamic db,
    String accountId,
  ) async {
    final result = await db.rawQuery(
      'SELECT SUM(balance) as total FROM $tableName WHERE account_id = ?',
      [accountId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Check if an invoice exists
  static Future<bool> exists(dynamic db, String invoiceId) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE invoice_id = ?',
      [invoiceId],
    );
    return (Sqflite.firstIntValue(result) ?? 0) > 0;
  }

  // Search invoices by invoice number
  static Future<List<AccountInvoiceModel>> searchByInvoiceNumber(
    dynamic db,
    String accountId,
    String searchTerm,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'account_id = ? AND invoice_number LIKE ?',
      whereArgs: [accountId, '%$searchTerm%'],
      orderBy: 'invoice_date DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get invoices by parent invoice ID
  static Future<List<AccountInvoiceModel>> getByParentInvoiceId(
    dynamic db,
    String parentInvoiceId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'parent_invoice_id = ?',
      whereArgs: [parentInvoiceId],
      orderBy: 'invoice_date DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get parent invoices only
  static Future<List<AccountInvoiceModel>> getParentInvoices(
    dynamic db,
    String accountId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'account_id = ? AND is_parent_invoice = 1',
      whereArgs: [accountId],
      orderBy: 'invoice_date DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get child invoices only
  static Future<List<AccountInvoiceModel>> getChildInvoices(
    dynamic db,
    String accountId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'account_id = ? AND is_parent_invoice = 0',
      whereArgs: [accountId],
      orderBy: 'invoice_date DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get invoices with overdue status
  static Future<List<AccountInvoiceModel>> getOverdueInvoices(
    dynamic db,
    String accountId,
  ) async {
    final now = DateTime.now().toIso8601String();
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'account_id = ? AND target_date < ? AND balance > 0',
      whereArgs: [accountId, now],
      orderBy: 'target_date ASC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get invoices due soon (within specified days)
  static Future<List<AccountInvoiceModel>> getInvoicesDueSoon(
    dynamic db,
    String accountId,
    int daysAhead,
  ) async {
    final now = DateTime.now();
    final dueDate = now.add(Duration(days: daysAhead)).toIso8601String();
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'account_id = ? AND target_date BETWEEN ? AND ? AND balance > 0',
      whereArgs: [now.toIso8601String(), dueDate],
      orderBy: 'target_date ASC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }
}
