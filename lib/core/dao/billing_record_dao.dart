import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:logger/logger.dart';

class BillingRecordModel {
  final int? id;
  final String userId;
  final double amount;
  final String? description;
  final DateTime? dueDate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BillingRecordModel({
    this.id,
    required this.userId,
    required this.amount,
    this.description,
    this.dueDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory BillingRecordModel.fromJson(Map<String, dynamic> json) {
    return BillingRecordModel(
      id: json['id'] as int?,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  BillingRecordModel copyWith({
    int? id,
    String? userId,
    double? amount,
    String? description,
    DateTime? dueDate,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BillingRecordModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'BillingRecordModel(id: $id, userId: $userId, amount: $amount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BillingRecordModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class BillingRecordDao {
  static const String tableName = 'billing_records';
  static final Logger _logger = Logger();

  // Column names constants
  static const String columnId = 'id';
  static const String columnUserId = 'user_id';
  static const String columnAmount = 'amount';
  static const String columnDescription = 'description';
  static const String columnDueDate = 'due_date';
  static const String columnStatus = 'status';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  static const String createTableSQL =
      '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnUserId TEXT NOT NULL,
      $columnAmount REAL NOT NULL,
      $columnDescription TEXT,
      $columnDueDate TEXT,
      $columnStatus TEXT NOT NULL,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL,
      FOREIGN KEY ($columnUserId) REFERENCES users (id) ON DELETE CASCADE
    )
  ''';

  static Map<String, dynamic> toMap(BillingRecordModel billingRecord) {
    return {
      columnId: billingRecord.id,
      columnUserId: billingRecord.userId,
      columnAmount: billingRecord.amount,
      columnDescription: billingRecord.description,
      columnDueDate: billingRecord.dueDate?.toIso8601String(),
      columnStatus: billingRecord.status,
      columnCreatedAt: billingRecord.createdAt.toIso8601String(),
      columnUpdatedAt: billingRecord.updatedAt.toIso8601String(),
    };
  }

  static BillingRecordModel fromMap(Map<String, dynamic> map) {
    return BillingRecordModel(
      id: map[columnId] as int?,
      userId: map[columnUserId] as String,
      amount: map[columnAmount] as double,
      description: map[columnDescription] as String?,
      dueDate: map[columnDueDate] != null
          ? DateTime.parse(map[columnDueDate] as String)
          : null,
      status: map[columnStatus] as String,
      createdAt: DateTime.parse(map[columnCreatedAt] as String),
      updatedAt: DateTime.parse(map[columnUpdatedAt] as String),
    );
  }

  /// Insert or update a billing record
  static Future<void> insertOrUpdate(
    Database db,
    BillingRecordModel billingRecord,
  ) async {
    try {
      final map = toMap(billingRecord);
      await db.insert(
        tableName,
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _logger.d(
        'Billing record inserted/updated successfully: ${billingRecord.id} for user: ${billingRecord.userId}',
      );
    } catch (e) {
      _logger.e('Error inserting billing record: $e');
      rethrow;
    }
  }

  /// Insert multiple billing records
  static Future<void> insertMultiple(
    Database db,
    List<BillingRecordModel> billingRecords,
  ) async {
    try {
      await db.transaction((txn) async {
        for (final billingRecord in billingRecords) {
          final map = toMap(billingRecord);
          await txn.insert(
            tableName,
            map,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
      _logger.d(
        'Inserted ${billingRecords.length} billing records successfully',
      );
    } catch (e) {
      _logger.e('Error inserting multiple billing records: $e');
      rethrow;
    }
  }

  /// Get a billing record by ID
  static Future<BillingRecordModel?> getById(Database db, int id) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnId = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        _logger.d('Billing record retrieved successfully: $id');
        return fromMap(maps.first);
      }
      _logger.d('Billing record not found: $id');
      return null;
    } catch (e) {
      _logger.e('Error retrieving billing record by ID: $e');
      rethrow;
    }
  }

  /// Get all billing records for a specific user
  static Future<List<BillingRecordModel>> getByUserId(
    Database db,
    String userId,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnUserId = ?',
        whereArgs: [userId],
        orderBy: '$columnCreatedAt DESC',
      );

      final records = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${records.length} billing records for user: $userId',
      );
      return records;
    } catch (e) {
      _logger.e('Error retrieving billing records by user ID: $e');
      rethrow;
    }
  }

  /// Get billing records by status
  static Future<List<BillingRecordModel>> getByStatus(
    Database db,
    String userId,
    String status,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnUserId = ? AND $columnStatus = ?',
        whereArgs: [userId, status],
        orderBy: '$columnCreatedAt DESC',
      );

      final records = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${records.length} billing records with status $status for user: $userId',
      );
      return records;
    } catch (e) {
      _logger.e('Error retrieving billing records by status: $e');
      rethrow;
    }
  }

  /// Get billing records by date range
  static Future<List<BillingRecordModel>> getByDateRange(
    Database db,
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnUserId = ? AND $columnCreatedAt BETWEEN ? AND ?',
        whereArgs: [
          userId,
          startDate.toIso8601String(),
          endDate.toIso8601String(),
        ],
        orderBy: '$columnCreatedAt DESC',
      );

      final records = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${records.length} billing records for user: $userId between ${startDate.toIso8601String()} and ${endDate.toIso8601String()}',
      );
      return records;
    } catch (e) {
      _logger.e('Error retrieving billing records by date range: $e');
      rethrow;
    }
  }

  /// Get overdue billing records
  static Future<List<BillingRecordModel>> getOverdueRecords(
    Database db,
    String userId,
  ) async {
    try {
      final now = DateTime.now().toIso8601String();
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where:
            '$columnUserId = ? AND $columnDueDate < ? AND $columnStatus != ?',
        whereArgs: [userId, now, 'PAID'],
        orderBy: '$columnDueDate ASC',
      );

      final records = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${records.length} overdue billing records for user: $userId',
      );
      return records;
    } catch (e) {
      _logger.e('Error retrieving overdue billing records: $e');
      rethrow;
    }
  }

  /// Get upcoming billing records
  static Future<List<BillingRecordModel>> getUpcomingRecords(
    Database db,
    String userId,
    int daysAhead,
  ) async {
    try {
      final now = DateTime.now();
      final futureDate = now.add(Duration(days: daysAhead));
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where:
            '$columnUserId = ? AND $columnDueDate BETWEEN ? AND ? AND $columnStatus != ?',
        whereArgs: [
          userId,
          now.toIso8601String(),
          futureDate.toIso8601String(),
          'PAID',
        ],
        orderBy: '$columnDueDate ASC',
      );

      final records = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${records.length} upcoming billing records for user: $userId in next $daysAhead days',
      );
      return records;
    } catch (e) {
      _logger.e('Error retrieving upcoming billing records: $e');
      rethrow;
    }
  }

  /// Get billing records with pagination
  static Future<List<BillingRecordModel>> getWithPagination(
    Database db,
    String userId,
    int page,
    int pageSize,
  ) async {
    try {
      final offset = page * pageSize;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnUserId = ?',
        whereArgs: [userId],
        orderBy: '$columnCreatedAt DESC',
        limit: pageSize,
        offset: offset,
      );

      final records = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${records.length} billing records for user: $userId (page $page, size $pageSize)',
      );
      return records;
    } catch (e) {
      _logger.e('Error retrieving billing records with pagination: $e');
      rethrow;
    }
  }

  /// Get all billing records
  static Future<List<BillingRecordModel>> getAll(Database db) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        orderBy: '$columnCreatedAt DESC',
      );

      final records = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d('Retrieved ${records.length} billing records');
      return records;
    } catch (e) {
      _logger.e('Error retrieving all billing records: $e');
      rethrow;
    }
  }

  /// Update a billing record
  static Future<void> update(
    Database db,
    BillingRecordModel billingRecord,
  ) async {
    try {
      final map = toMap(billingRecord);
      map[columnUpdatedAt] = DateTime.now().toIso8601String();

      await db.update(
        tableName,
        map,
        where: '$columnId = ?',
        whereArgs: [billingRecord.id],
      );
      _logger.d(
        'Billing record updated successfully: ${billingRecord.id} for user: ${billingRecord.userId}',
      );
    } catch (e) {
      _logger.e('Error updating billing record: $e');
      rethrow;
    }
  }

  /// Update billing record status
  static Future<void> updateStatus(
    Database db,
    int id,
    String newStatus,
  ) async {
    try {
      await db.update(
        tableName,
        {
          columnStatus: newStatus,
          columnUpdatedAt: DateTime.now().toIso8601String(),
        },
        where: '$columnId = ?',
        whereArgs: [id],
      );
      _logger.d('Billing record status updated for $id to $newStatus');
    } catch (e) {
      _logger.e('Error updating billing record status: $e');
      rethrow;
    }
  }

  /// Delete a billing record
  static Future<void> delete(Database db, int id) async {
    try {
      await db.delete(tableName, where: '$columnId = ?', whereArgs: [id]);
      _logger.d('Billing record deleted successfully: $id');
    } catch (e) {
      _logger.e('Error deleting billing record: $e');
      rethrow;
    }
  }

  /// Delete billing records by user ID
  static Future<void> deleteByUserId(Database db, String userId) async {
    try {
      await db.delete(
        tableName,
        where: '$columnUserId = ?',
        whereArgs: [userId],
      );
      _logger.d('Billing records deleted successfully for user: $userId');
    } catch (e) {
      _logger.e('Error deleting billing records by user ID: $e');
      rethrow;
    }
  }

  /// Delete all billing records
  static Future<void> deleteAll(Database db) async {
    try {
      await db.delete(tableName);
      _logger.d('All billing records deleted successfully');
    } catch (e) {
      _logger.e('Error deleting all billing records: $e');
      rethrow;
    }
  }

  /// Get count of billing records for a specific user
  static Future<int> getCountByUserId(Database db, String userId) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE $columnUserId = ?',
        [userId],
      );
      final count = Sqflite.firstIntValue(result) ?? 0;
      _logger.d('Billing record count for user $userId: $count');
      return count;
    } catch (e) {
      _logger.e('Error getting billing record count by user ID: $e');
      rethrow;
    }
  }

  /// Get count by status for a specific user
  static Future<int> getCountByStatus(
    Database db,
    String userId,
    String status,
  ) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE $columnUserId = ? AND $columnStatus = ?',
        [userId, status],
      );
      final count = Sqflite.firstIntValue(result) ?? 0;
      _logger.d(
        'Billing record count for user $userId and status $status: $count',
      );
      return count;
    } catch (e) {
      _logger.e('Error getting billing record count by status: $e');
      rethrow;
    }
  }

  /// Get total count of all billing records
  static Future<int> getTotalCount(Database db) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName',
      );
      final count = Sqflite.firstIntValue(result) ?? 0;
      _logger.d('Total billing record count: $count');
      return count;
    } catch (e) {
      _logger.e('Error getting total billing record count: $e');
      rethrow;
    }
  }

  /// Get total amount by status for a specific user
  static Future<double> getTotalAmountByStatus(
    Database db,
    String userId,
    String status,
  ) async {
    try {
      final result = await db.rawQuery(
        'SELECT SUM($columnAmount) as total FROM $tableName WHERE $columnUserId = ? AND $columnStatus = ?',
        [userId, status],
      );
      final total = (result.first['total'] as num?)?.toDouble() ?? 0.0;
      _logger.d('Total amount for user $userId and status $status: $total');
      return total;
    } catch (e) {
      _logger.e('Error getting total amount by status: $e');
      rethrow;
    }
  }

  /// Get total amount for a specific user
  static Future<double> getTotalAmountByUserId(
    Database db,
    String userId,
  ) async {
    try {
      final result = await db.rawQuery(
        'SELECT SUM($columnAmount) as total FROM $tableName WHERE $columnUserId = ?',
        [userId],
      );
      final total = (result.first['total'] as num?)?.toDouble() ?? 0.0;
      _logger.d('Total amount for user $userId: $total');
      return total;
    } catch (e) {
      _logger.e('Error getting total amount by user ID: $e');
      rethrow;
    }
  }

  /// Check if a billing record exists
  static Future<bool> exists(Database db, int id) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE $columnId = ?',
        [id],
      );
      final exists = (Sqflite.firstIntValue(result) ?? 0) > 0;
      _logger.d('Billing record exists check for $id: $exists');
      return exists;
    } catch (e) {
      _logger.e('Error checking if billing record exists: $e');
      rethrow;
    }
  }

  /// Search billing records by description
  static Future<List<BillingRecordModel>> searchByDescription(
    Database db,
    String userId,
    String searchTerm,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnUserId = ? AND $columnDescription LIKE ?',
        whereArgs: [userId, '%$searchTerm%'],
        orderBy: '$columnCreatedAt DESC',
      );

      final records = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Found ${records.length} billing records matching "$searchTerm" for user: $userId',
      );
      return records;
    } catch (e) {
      _logger.e('Error searching billing records by description: $e');
      rethrow;
    }
  }

  /// Get recent billing records for a specific user
  static Future<List<BillingRecordModel>> getRecentRecords(
    Database db,
    String userId,
    int limit,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnUserId = ?',
        whereArgs: [userId],
        orderBy: '$columnCreatedAt DESC',
        limit: limit,
      );

      final records = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${records.length} recent billing records for user: $userId',
      );
      return records;
    } catch (e) {
      _logger.e('Error retrieving recent billing records: $e');
      rethrow;
    }
  }

  /// Get high amount billing records
  static Future<List<BillingRecordModel>> getHighAmountRecords(
    Database db,
    String userId,
    double threshold,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnUserId = ? AND $columnAmount > ?',
        whereArgs: [userId, threshold],
        orderBy: '$columnAmount DESC, $columnCreatedAt DESC',
      );

      final records = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${records.length} high amount billing records (>$threshold) for user: $userId',
      );
      return records;
    } catch (e) {
      _logger.e('Error retrieving high amount billing records: $e');
      rethrow;
    }
  }

  /// Get paid billing records for a specific user
  static Future<List<BillingRecordModel>> getPaidRecords(
    Database db,
    String userId,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnUserId = ? AND $columnStatus = ?',
        whereArgs: [userId, 'PAID'],
        orderBy: '$columnCreatedAt DESC',
      );

      final records = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${records.length} paid billing records for user: $userId',
      );
      return records;
    } catch (e) {
      _logger.e('Error retrieving paid billing records: $e');
      rethrow;
    }
  }

  /// Get pending billing records for a specific user
  static Future<List<BillingRecordModel>> getPendingRecords(
    Database db,
    String userId,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnUserId = ? AND $columnStatus = ?',
        whereArgs: [userId, 'PENDING'],
        orderBy: '$columnCreatedAt DESC',
      );

      final records = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${records.length} pending billing records for user: $userId',
      );
      return records;
    } catch (e) {
      _logger.e('Error retrieving pending billing records: $e');
      rethrow;
    }
  }

  /// Get failed billing records for a specific user
  static Future<List<BillingRecordModel>> getFailedRecords(
    Database db,
    String userId,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnUserId = ? AND $columnStatus = ?',
        whereArgs: [userId, 'FAILED'],
        orderBy: '$columnCreatedAt DESC',
      );

      final records = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${records.length} failed billing records for user: $userId',
      );
      return records;
    } catch (e) {
      _logger.e('Error retrieving failed billing records: $e');
      rethrow;
    }
  }
}
