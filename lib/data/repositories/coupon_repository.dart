import '../database/database_helper.dart';
import '../database/db_constants.dart';
import '../models/coupon.dart';

class CouponRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Coupon>> getAllCoupons() async {
    final maps = await _dbHelper.queryAll(
      DbConstants.tableCoupons,
      orderBy: '${DbConstants.colCode} ASC',
    );
    return maps.map((map) => Coupon.fromMap(map)).toList();
  }

  Future<Coupon?> getCouponByCode(String code) async {
    final maps = await _dbHelper.queryWhere(
      DbConstants.tableCoupons,
      where: '${DbConstants.colCode} = ?',
      whereArgs: [code.toUpperCase()],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Coupon.fromMap(maps.first);
  }

  Future<int> addCoupon(Coupon coupon) async {
    return await _dbHelper.insert(
      DbConstants.tableCoupons,
      coupon.toMap(),
    );
  }

  Future<int> updateCoupon(Coupon coupon) async {
    return await _dbHelper.update(
      DbConstants.tableCoupons,
      coupon.toMap(),
      where: '${DbConstants.colId} = ?',
      whereArgs: [coupon.id],
    );
  }

  Future<void> incrementUsage(String code) async {
    final db = await _dbHelper.database;
    await db.rawUpdate(
      '''
      UPDATE ${DbConstants.tableCoupons}
      SET ${DbConstants.colUsageCount} = ${DbConstants.colUsageCount} + 1
      WHERE ${DbConstants.colCode} = ?
      ''',
      [code.toUpperCase()],
    );
  }

  Future<int> deactivateCoupon(int id) async {
    return await _dbHelper.update(
      DbConstants.tableCoupons,
      {DbConstants.colIsActive: 0},
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
  }
}
