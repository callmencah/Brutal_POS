import '../database/database_helper.dart';
import '../database/db_constants.dart';
import '../models/transaction.dart';
import '../models/transaction_item.dart';

class TransactionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> saveTransaction(
    Transaction tx,
    List<TransactionItem> items,
  ) async {
    final db = await _dbHelper.database;
    int transactionId = 0;

    await db.transaction((txn) async {
      transactionId = await txn.insert(
        DbConstants.tableTransactions,
        tx.toMap(),
      );

      for (final item in items) {
        final itemMap = item.copyWith(transactionId: transactionId).toMap();
        await txn.insert(DbConstants.tableTransactionItems, itemMap);
      }
    });

    return transactionId;
  }

  Future<List<Transaction>> getAllTransactions() async {
    final maps = await _dbHelper.queryAll(
      DbConstants.tableTransactions,
      orderBy: '${DbConstants.colCreatedAt} DESC',
    );
    return maps.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<List<Transaction>> getTransactionsToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final maps = await _dbHelper.queryWhere(
      DbConstants.tableTransactions,
      where: '${DbConstants.colCreatedAt} >= ? AND ${DbConstants.colCreatedAt} < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: '${DbConstants.colCreatedAt} DESC',
    );
    return maps.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<List<Transaction>> getTransactionsThisWeek() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final end = start.add(const Duration(days: 7));

    final maps = await _dbHelper.queryWhere(
      DbConstants.tableTransactions,
      where: '${DbConstants.colCreatedAt} >= ? AND ${DbConstants.colCreatedAt} < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: '${DbConstants.colCreatedAt} DESC',
    );
    return maps.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<List<Transaction>> getTransactionsThisMonth() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);

    final maps = await _dbHelper.queryWhere(
      DbConstants.tableTransactions,
      where: '${DbConstants.colCreatedAt} >= ? AND ${DbConstants.colCreatedAt} < ?',
      whereArgs: [startOfMonth.toIso8601String(), endOfMonth.toIso8601String()],
      orderBy: '${DbConstants.colCreatedAt} DESC',
    );
    return maps.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<Transaction?> getTransactionById(int id) async {
    final map = await _dbHelper.queryById(DbConstants.tableTransactions, id);
    if (map == null) return null;

    final itemMaps = await _dbHelper.queryWhere(
      DbConstants.tableTransactionItems,
      where: '${DbConstants.colTransactionId} = ?',
      whereArgs: [id],
    );

    final items = itemMaps.map((m) => TransactionItem.fromMap(m)).toList();
    return Transaction.fromMap(map, items: items);
  }

  Future<Map<String, dynamic>> getTodaySummary() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await _dbHelper.rawQuery(
      '''
      SELECT 
        COALESCE(SUM(${DbConstants.colTotal}), 0) as total,
        COUNT(*) as count,
        COALESCE(AVG(${DbConstants.colTotal}), 0) as average
      FROM ${DbConstants.tableTransactions}
      WHERE ${DbConstants.colCreatedAt} >= ? AND ${DbConstants.colCreatedAt} < ?
        AND ${DbConstants.colStatus} != 'voided'
      ''',
      [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );

    if (result.isEmpty) {
      return {'total': 0.0, 'count': 0, 'average': 0.0};
    }

    return {
      'total': (result.first['total'] as num).toDouble(),
      'count': result.first['count'] as int,
      'average': (result.first['average'] as num).toDouble(),
    };
  }

  Future<List<Map<String, dynamic>>> getWeekDailySummary() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    final List<Map<String, dynamic>> dailySummaries = [];

    for (int i = 0; i < 7; i++) {
      final dayStart = start.add(Duration(days: i));
      final dayEnd = dayStart.add(const Duration(days: 1));

      final result = await _dbHelper.rawQuery(
        '''
        SELECT 
          COALESCE(SUM(${DbConstants.colTotal}), 0) as total,
          COUNT(*) as count
        FROM ${DbConstants.tableTransactions}
        WHERE ${DbConstants.colCreatedAt} >= ? AND ${DbConstants.colCreatedAt} < ?
          AND ${DbConstants.colStatus} != 'voided'
        ''',
        [dayStart.toIso8601String(), dayEnd.toIso8601String()],
      );

      dailySummaries.add({
        'date': dayStart,
        'dayOfWeek': dayStart.weekday,
        'total': result.isNotEmpty
            ? (result.first['total'] as num).toDouble()
            : 0.0,
        'count': result.isNotEmpty ? result.first['count'] as int : 0,
      });
    }

    return dailySummaries;
  }


  Future<List<Map<String, dynamic>>> getYearMonthlySummary() async {
    final now = DateTime.now();
    final List<Map<String, dynamic>> monthlySummaries = [];

    for (int i = 1; i <= 12; i++) {
      final monthStart = DateTime(now.year, i, 1);
      final monthEnd = i < 12 ? DateTime(now.year, i + 1, 1) : DateTime(now.year + 1, 1, 1);

      final result = await _dbHelper.rawQuery(
        '''
        SELECT 
          COALESCE(SUM(${DbConstants.colTotal}), 0) as total,
          COUNT(*) as count
        FROM ${DbConstants.tableTransactions}
        WHERE ${DbConstants.colCreatedAt} >= ? AND ${DbConstants.colCreatedAt} < ?
          AND ${DbConstants.colStatus} != 'voided'
        ''',
        [monthStart.toIso8601String(), monthEnd.toIso8601String()],
      );

      monthlySummaries.add({
        'month': i,
        'total': result.first['total'],
        'count': result.first['count'],
      });
    }

    return monthlySummaries;
  }

  Future<List<Map<String, dynamic>>> getTopProducts(int limit) async {
    final result = await _dbHelper.rawQuery(
      '''
      SELECT 
        ti.${DbConstants.colProductName},
        ti.${DbConstants.colProductId},
        SUM(ti.${DbConstants.colQuantity}) as total_qty,
        SUM(ti.${DbConstants.colSubtotal}) as total_revenue
      FROM ${DbConstants.tableTransactionItems} ti
      INNER JOIN ${DbConstants.tableTransactions} t
        ON ti.${DbConstants.colTransactionId} = t.${DbConstants.colId}
      WHERE t.${DbConstants.colStatus} != 'voided'
      GROUP BY ti.${DbConstants.colProductId}
      ORDER BY total_qty DESC
      LIMIT ?
      ''',
      [limit],
    );

    return result
        .map((row) => {
              'productId': row['product_id'] as int,
              'productName': row['product_name'] as String,
              'totalQty': (row['total_qty'] as num).toInt(),
              'totalRevenue': (row['total_revenue'] as num).toDouble(),
            })
        .toList();
  }

  /// Voids a transaction by setting its status to 'voided' with a reason and timestamp.
  Future<int> voidTransaction(int id, String reason) async {
    final now = DateTime.now();
    return await _dbHelper.update(
      DbConstants.tableTransactions,
      {
        DbConstants.colStatus: 'voided',
        DbConstants.colVoidedAt: now.toIso8601String(),
        DbConstants.colVoidReason: reason,
      },
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
  }
}

