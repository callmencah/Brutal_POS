import '../database/database_helper.dart';
import '../database/db_constants.dart';
import '../models/category.dart';
import '../models/product.dart';

class ProductRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Product>> getAllProducts() async {
    final maps = await _dbHelper.queryAll(
      DbConstants.tableProducts,
      orderBy: '${DbConstants.colCategoryId} ASC, ${DbConstants.colName} ASC',
    );
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  Future<List<Product>> getProductsByCategory(int categoryId) async {
    final maps = await _dbHelper.queryWhere(
      DbConstants.tableProducts,
      where: '${DbConstants.colCategoryId} = ?',
      whereArgs: [categoryId],
      orderBy: '${DbConstants.colName} ASC',
    );
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  Future<List<Product>> searchProducts(String query) async {
    final maps = await _dbHelper.queryWhere(
      DbConstants.tableProducts,
      where: '${DbConstants.colName} LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: '${DbConstants.colName} ASC',
    );
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  Future<Product?> getProductById(int id) async {
    final map = await _dbHelper.queryById(DbConstants.tableProducts, id);
    if (map == null) return null;
    return Product.fromMap(map);
  }

  Future<List<Category>> getAllCategories() async {
    final maps = await _dbHelper.queryAll(
      DbConstants.tableCategories,
      orderBy: '${DbConstants.colId} ASC',
    );
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  Future<int> addProduct(Product product) async {
    return await _dbHelper.insert(DbConstants.tableProducts, product.toMap());
  }

  Future<int> updateProduct(Product product) async {
    return await _dbHelper.update(
      DbConstants.tableProducts,
      product.toMap(),
      where: '${DbConstants.colId} = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    return await _dbHelper.delete(
      DbConstants.tableProducts,
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  /// Decrements stock for a product by the given quantity.
  /// Only updates products that have a non-null stock value.
  Future<int> decrementStock(int productId, int quantity) async {
    return await _dbHelper.rawUpdate(
      'UPDATE ${DbConstants.tableProducts} SET ${DbConstants.colStock} = ${DbConstants.colStock} - ? WHERE ${DbConstants.colId} = ? AND ${DbConstants.colStock} IS NOT NULL',
      [quantity, productId],
    );
  }

  /// Restores stock for a product by the given quantity.
  /// Only updates products that have a non-null stock value.
  Future<int> restoreStock(int productId, int quantity) async {
    return await _dbHelper.rawUpdate(
      'UPDATE ${DbConstants.tableProducts} SET ${DbConstants.colStock} = ${DbConstants.colStock} + ? WHERE ${DbConstants.colId} = ? AND ${DbConstants.colStock} IS NOT NULL',
      [quantity, productId],
    );
  }
}
