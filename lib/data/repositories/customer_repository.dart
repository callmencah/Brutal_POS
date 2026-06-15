import '../database/database_helper.dart';
import '../database/db_constants.dart';
import '../models/customer.dart';

class CustomerRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Customer>> getAllCustomers() async {
    final maps = await _dbHelper.queryAll(
      DbConstants.tableCustomers,
      orderBy: '${DbConstants.colName} ASC',
    );
    return maps.map((map) => Customer.fromMap(map)).toList();
  }

  Future<int> addCustomer(Customer customer) async {
    return await _dbHelper.insert(
      DbConstants.tableCustomers,
      customer.toMap(),
    );
  }

  Future<Customer?> getCustomerById(int id) async {
    final map = await _dbHelper.queryById(DbConstants.tableCustomers, id);
    if (map == null) return null;
    return Customer.fromMap(map);
  }

  Future<int> updateCustomer(Customer customer) async {
    return await _dbHelper.update(
      DbConstants.tableCustomers,
      customer.toMap(),
      where: '${DbConstants.colId} = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(int id) async {
    return await _dbHelper.delete(
      DbConstants.tableCustomers,
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  Future<List<Customer>> searchCustomers(String query) async {
    final maps = await _dbHelper.queryWhere(
      DbConstants.tableCustomers,
      where:
          '${DbConstants.colName} LIKE ? OR ${DbConstants.colPhone} LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: '${DbConstants.colName} ASC',
    );
    return maps.map((map) => Customer.fromMap(map)).toList();
  }
}
