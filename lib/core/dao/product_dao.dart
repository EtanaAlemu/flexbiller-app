import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../features/products/data/models/product_model.dart';

class ProductDao {
  static const String tableName = 'products';

  // Column names
  static const String columnId = 'id';
  static const String columnUserId = 'user_id';
  static const String columnProductName = 'product_name';
  static const String columnProductDescription = 'product_description';
  static const String columnTenantId = 'tenant_id';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
  static const String columnCreatedBy = 'created_by';
  static const String columnUpdatedBy = 'updated_by';

  static const String createTableSQL =
      '''
    CREATE TABLE IF NOT EXISTS $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnUserId TEXT NOT NULL,
      $columnProductName TEXT NOT NULL,
      $columnProductDescription TEXT NOT NULL,
      $columnTenantId TEXT NOT NULL,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL,
      $columnCreatedBy TEXT NOT NULL,
      $columnUpdatedBy TEXT NOT NULL,
      FOREIGN KEY ($columnUserId) REFERENCES users (id) ON DELETE CASCADE
    )
  ''';

  static const String createIndexesSQL =
      '''
    CREATE INDEX IF NOT EXISTS idx_products_user_id ON $tableName ($columnUserId);
    CREATE INDEX IF NOT EXISTS idx_products_tenant_id ON $tableName ($columnTenantId);
    CREATE INDEX IF NOT EXISTS idx_products_product_name ON $tableName ($columnProductName);
    CREATE INDEX IF NOT EXISTS idx_products_created_at ON $tableName ($columnCreatedAt)
  ''';

  static Future<void> insertOrUpdate(
    Database db,
    ProductModel product, {
    required String userId,
  }) async {
    final productData = {
      columnId: product.id,
      columnUserId: userId,
      columnProductName: product.productName,
      columnProductDescription: product.productDescription,
      columnTenantId: product.tenantId,
      columnCreatedAt: product.createdAt.toIso8601String(),
      columnUpdatedAt: product.updatedAt.toIso8601String(),
      columnCreatedBy: product.createdBy,
      columnUpdatedBy: product.updatedBy,
    };

    await db.insert(
      tableName,
      productData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<ProductModel?> getById(Database db, String id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return _mapToProductModel(maps.first);
    }
    return null;
  }

  static Future<List<ProductModel>> getAll(
    Database db, {
    String? orderBy,
    String? userId,
  }) async {
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (userId != null) {
      whereClause = 'WHERE $columnUserId = ?';
      whereArgs.add(userId);
    }

    final String query =
        '''
      SELECT * FROM $tableName 
      $whereClause
      ${orderBy != null ? 'ORDER BY $orderBy' : ''}
    ''';

    final List<Map<String, dynamic>> maps = await db.rawQuery(query, whereArgs);

    return maps.map((map) => _mapToProductModel(map)).toList();
  }

  static Future<List<ProductModel>> getByQuery(
    Database db, {
    int? limit,
    int? offset,
    String? orderBy,
    String? userId,
  }) async {
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (userId != null) {
      whereClause = 'WHERE $columnUserId = ?';
      whereArgs.add(userId);
    }

    String limitClause = '';
    if (limit != null) {
      limitClause = 'LIMIT $limit';
      if (offset != null) {
        limitClause += ' OFFSET $offset';
      }
    }

    final String query =
        '''
      SELECT * FROM $tableName 
      $whereClause
      ${orderBy != null ? 'ORDER BY $orderBy' : ''}
      $limitClause
    ''';

    final List<Map<String, dynamic>> maps = await db.rawQuery(query, whereArgs);

    return maps.map((map) => _mapToProductModel(map)).toList();
  }

  static Future<List<ProductModel>> search(
    Database db,
    String searchKey, {
    String? userId,
  }) async {
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (userId != null) {
      whereClause = '$columnUserId = ? AND (';
      whereArgs.add(userId);
    } else {
      whereClause = '(';
    }

    whereClause +=
        '$columnProductName LIKE ? OR $columnProductDescription LIKE ?)';
    whereArgs.add('%$searchKey%');
    whereArgs.add('%$searchKey%');

    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: '$columnProductName ASC',
    );

    return maps.map((map) => _mapToProductModel(map)).toList();
  }

  static Future<List<ProductModel>> getByTenantId(
    Database db,
    String tenantId, {
    String? userId,
  }) async {
    String whereClause = '$columnTenantId = ?';
    List<dynamic> whereArgs = [tenantId];

    if (userId != null) {
      whereClause += ' AND $columnUserId = ?';
      whereArgs.add(userId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: '$columnProductName ASC',
    );

    return maps.map((map) => _mapToProductModel(map)).toList();
  }

  static Future<void> deleteById(Database db, String id) async {
    await db.delete(tableName, where: '$columnId = ?', whereArgs: [id]);
  }

  static Future<int> getCount(Database db, {String? userId}) async {
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (userId != null) {
      whereClause = 'WHERE $columnUserId = ?';
      whereArgs.add(userId);
    }

    final String query =
        '''
      SELECT COUNT(*) as count FROM $tableName 
      $whereClause
    ''';

    final List<Map<String, dynamic>> result = await db.rawQuery(
      query,
      whereArgs,
    );
    return result.first['count'] as int;
  }

  static Future<bool> hasProducts(Database db, {String? userId}) async {
    final count = await getCount(db, userId: userId);
    return count > 0;
  }

  static Future<void> deleteByUserId(Database db, String userId) async {
    await db.delete(tableName, where: '$columnUserId = ?', whereArgs: [userId]);
  }

  /// Maps database row to ProductModel
  static ProductModel _mapToProductModel(Map<String, dynamic> map) {
    return ProductModel(
      id: map[columnId] as String,
      productName: map[columnProductName] as String,
      productDescription: map[columnProductDescription] as String,
      tenantId: map[columnTenantId] as String,
      createdAt: DateTime.parse(map[columnCreatedAt] as String),
      updatedAt: DateTime.parse(map[columnUpdatedAt] as String),
      createdBy: map[columnCreatedBy] as String,
      updatedBy: map[columnUpdatedBy] as String,
      userId: map[columnUserId] as String?,
    );
  }
}
