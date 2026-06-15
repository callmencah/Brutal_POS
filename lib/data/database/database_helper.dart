import 'package:sqflite/sqflite.dart';

import 'db_constants.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/${DbConstants.databaseName}';
    return await openDatabase(
      path,
      version: DbConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await db.execute(
        'ALTER TABLE ${DbConstants.tableTransactions} ADD COLUMN ${DbConstants.colServiceChargeAmount} REAL NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE ${DbConstants.tableTransactions} ADD COLUMN ${DbConstants.colRoundUpAmount} REAL NOT NULL DEFAULT 0',
      );
    }
    if (oldVersion < 3) {
      // Add image_path column to products table
      await db.execute(
        'ALTER TABLE ${DbConstants.tableProducts} ADD COLUMN ${DbConstants.colImagePath} TEXT',
      );
    }
    if (oldVersion < 2) {
      // Add stock column to products table
      await db.execute(
        'ALTER TABLE ${DbConstants.tableProducts} ADD COLUMN ${DbConstants.colStock} INTEGER',
      );

      // Add status, voided_at, void_reason columns to transactions table
      await db.execute(
        "ALTER TABLE ${DbConstants.tableTransactions} ADD COLUMN ${DbConstants.colStatus} TEXT NOT NULL DEFAULT 'completed'",
      );
      await db.execute(
        'ALTER TABLE ${DbConstants.tableTransactions} ADD COLUMN ${DbConstants.colVoidedAt} TEXT',
      );
      await db.execute(
        'ALTER TABLE ${DbConstants.tableTransactions} ADD COLUMN ${DbConstants.colVoidReason} TEXT',
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // ─── Categories Table ──────────────────────────────────────
    await db.execute('''
      CREATE TABLE ${DbConstants.tableCategories} (
        ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colNameId} TEXT NOT NULL,
        ${DbConstants.colNameEn} TEXT NOT NULL,
        ${DbConstants.colIcon} TEXT NOT NULL
      )
    ''');

    // ─── Products Table ────────────────────────────────────────
    await db.execute('''
      CREATE TABLE ${DbConstants.tableProducts} (
        ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colName} TEXT NOT NULL,
        ${DbConstants.colCategoryId} INTEGER NOT NULL,
        ${DbConstants.colPrice} REAL NOT NULL,
        ${DbConstants.colImageIcon} TEXT,
        ${DbConstants.colImagePath} TEXT,
        ${DbConstants.colIsAvailable} INTEGER NOT NULL DEFAULT 1,
        ${DbConstants.colStock} INTEGER,
        FOREIGN KEY (${DbConstants.colCategoryId}) REFERENCES ${DbConstants.tableCategories}(${DbConstants.colId})
      )
    ''');

    // ─── Customers Table ───────────────────────────────────────
    await db.execute('''
      CREATE TABLE ${DbConstants.tableCustomers} (
        ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colName} TEXT NOT NULL,
        ${DbConstants.colPhone} TEXT,
        ${DbConstants.colCreatedAt} TEXT NOT NULL
      )
    ''');

    // ─── Coupons Table ─────────────────────────────────────────
    await db.execute('''
      CREATE TABLE ${DbConstants.tableCoupons} (
        ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colCode} TEXT NOT NULL UNIQUE,
        ${DbConstants.colDescription} TEXT,
        ${DbConstants.colDiscountType} TEXT NOT NULL,
        ${DbConstants.colDiscountValue} REAL NOT NULL,
        ${DbConstants.colMinPurchase} REAL NOT NULL DEFAULT 0,
        ${DbConstants.colMaxDiscount} REAL,
        ${DbConstants.colIsActive} INTEGER NOT NULL DEFAULT 1,
        ${DbConstants.colValidUntil} TEXT,
        ${DbConstants.colUsageLimit} INTEGER NOT NULL DEFAULT 0,
        ${DbConstants.colUsageCount} INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // ─── Transactions Table ────────────────────────────────────
    await db.execute('''
      CREATE TABLE ${DbConstants.tableTransactions} (
        ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colCustomerId} INTEGER,
        ${DbConstants.colSubtotal} REAL NOT NULL,
        ${DbConstants.colTaxPercent} REAL NOT NULL,
        ${DbConstants.colTaxAmount} REAL NOT NULL,
        ${DbConstants.colDiscountAmount} REAL NOT NULL DEFAULT 0,
        ${DbConstants.colCouponCode} TEXT,
        ${DbConstants.colTotal} REAL NOT NULL,
        ${DbConstants.colServiceChargeAmount} REAL NOT NULL DEFAULT 0,
        ${DbConstants.colRoundUpAmount} REAL NOT NULL DEFAULT 0,
        ${DbConstants.colPaymentMethod} TEXT NOT NULL,
        ${DbConstants.colAmountPaid} REAL,
        ${DbConstants.colChangeAmount} REAL NOT NULL DEFAULT 0,
        ${DbConstants.colCreatedAt} TEXT NOT NULL,
        ${DbConstants.colStatus} TEXT NOT NULL DEFAULT 'completed',
        ${DbConstants.colVoidedAt} TEXT,
        ${DbConstants.colVoidReason} TEXT,
        FOREIGN KEY (${DbConstants.colCustomerId}) REFERENCES ${DbConstants.tableCustomers}(${DbConstants.colId})
      )
    ''');

    // ─── Transaction Items Table ───────────────────────────────
    await db.execute('''
      CREATE TABLE ${DbConstants.tableTransactionItems} (
        ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colTransactionId} INTEGER NOT NULL,
        ${DbConstants.colProductId} INTEGER NOT NULL,
        ${DbConstants.colProductName} TEXT NOT NULL,
        ${DbConstants.colQuantity} INTEGER NOT NULL,
        ${DbConstants.colUnitPrice} REAL NOT NULL,
        ${DbConstants.colSubtotal} REAL NOT NULL,
        FOREIGN KEY (${DbConstants.colTransactionId}) REFERENCES ${DbConstants.tableTransactions}(${DbConstants.colId})
      )
    ''');

    // ─── Settings Table ────────────────────────────────────────
    await db.execute('''
      CREATE TABLE ${DbConstants.tableSettings} (
        ${DbConstants.colKey} TEXT PRIMARY KEY,
        ${DbConstants.colValue} TEXT NOT NULL
      )
    ''');

    // ─── Seed Data ─────────────────────────────────────────────
    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    // ─── Categories ────────────────────────────────────────────
    final categories = [
      {'name_id': 'Kopi', 'name_en': 'Coffee', 'icon': '☕'},
      {'name_id': 'Non-Kopi', 'name_en': 'Non-Coffee', 'icon': '🍵'},
      {'name_id': 'Makanan', 'name_en': 'Food', 'icon': '🍛'},
      {'name_id': 'Snack', 'name_en': 'Snacks', 'icon': '🍟'},
      {'name_id': 'Dessert', 'name_en': 'Dessert', 'icon': '🍰'},
      {'name_id': 'Minuman Botol', 'name_en': 'Bottled Drinks', 'icon': '🥤'},
    ];

    for (final cat in categories) {
      await db.insert(DbConstants.tableCategories, cat);
    }

    // ─── Products ──────────────────────────────────────────────
    // Category 1: Kopi
    final kopiProducts = [
      {'name': 'Americano', 'category_id': 1, 'price': 18000.0, 'image_icon': '☕', 'is_available': 1, 'stock': 50},
      {'name': 'Latte', 'category_id': 1, 'price': 24000.0, 'image_icon': '☕', 'is_available': 1, 'stock': 50},
      {'name': 'Cappuccino', 'category_id': 1, 'price': 24000.0, 'image_icon': '☕', 'is_available': 1, 'stock': 50},
      {'name': 'Espresso', 'category_id': 1, 'price': 15000.0, 'image_icon': '☕', 'is_available': 1, 'stock': 50},
      {'name': 'Mocha', 'category_id': 1, 'price': 28000.0, 'image_icon': '🍫', 'is_available': 1, 'stock': 50},
      {'name': 'Affogato', 'category_id': 1, 'price': 30000.0, 'image_icon': '🍨', 'is_available': 1, 'stock': 50},
    ];

    // Category 2: Non-Kopi
    final nonKopiProducts = [
      {'name': 'Matcha Latte', 'category_id': 2, 'price': 26000.0, 'image_icon': '🍵', 'is_available': 1, 'stock': 50},
      {'name': 'Hot Chocolate', 'category_id': 2, 'price': 24000.0, 'image_icon': '🍫', 'is_available': 1, 'stock': 50},
      {'name': 'Thai Tea', 'category_id': 2, 'price': 22000.0, 'image_icon': '🧋', 'is_available': 1, 'stock': 50},
      {'name': 'Taro Latte', 'category_id': 2, 'price': 24000.0, 'image_icon': '🟣', 'is_available': 1, 'stock': 50},
      {'name': 'Red Velvet', 'category_id': 2, 'price': 26000.0, 'image_icon': '❤️', 'is_available': 1, 'stock': 50},
    ];

    // Category 3: Makanan
    final makananProducts = [
      {'name': 'Nasi Goreng', 'category_id': 3, 'price': 32000.0, 'image_icon': '🍚', 'is_available': 1, 'stock': 50},
      {'name': 'Mie Goreng', 'category_id': 3, 'price': 30000.0, 'image_icon': '🍜', 'is_available': 1, 'stock': 50},
      {'name': 'Chicken Katsu', 'category_id': 3, 'price': 35000.0, 'image_icon': '🍗', 'is_available': 1, 'stock': 50},
      {'name': 'Beef Burger', 'category_id': 3, 'price': 38000.0, 'image_icon': '🍔', 'is_available': 1, 'stock': 50},
      {'name': 'Club Sandwich', 'category_id': 3, 'price': 34000.0, 'image_icon': '🥪', 'is_available': 1, 'stock': 50},
    ];

    // Category 4: Snack
    final snackProducts = [
      {'name': 'French Fries', 'category_id': 4, 'price': 20000.0, 'image_icon': '🍟', 'is_available': 1, 'stock': 50},
      {'name': 'Chicken Wings', 'category_id': 4, 'price': 28000.0, 'image_icon': '🍗', 'is_available': 1, 'stock': 50},
      {'name': 'Onion Rings', 'category_id': 4, 'price': 22000.0, 'image_icon': '🧅', 'is_available': 1, 'stock': 50},
      {'name': 'Nachos', 'category_id': 4, 'price': 25000.0, 'image_icon': '🌮', 'is_available': 1, 'stock': 50},
      {'name': 'Spring Roll', 'category_id': 4, 'price': 18000.0, 'image_icon': '🥟', 'is_available': 1, 'stock': 50},
    ];

    // Category 5: Dessert
    final dessertProducts = [
      {'name': 'Cheesecake', 'category_id': 5, 'price': 32000.0, 'image_icon': '🍰', 'is_available': 1, 'stock': 50},
      {'name': 'Brownies', 'category_id': 5, 'price': 25000.0, 'image_icon': '🍫', 'is_available': 1, 'stock': 50},
      {'name': 'Tiramisu', 'category_id': 5, 'price': 35000.0, 'image_icon': '🍮', 'is_available': 1, 'stock': 50},
      {'name': 'Pancake Stack', 'category_id': 5, 'price': 28000.0, 'image_icon': '🥞', 'is_available': 1, 'stock': 50},
      {'name': 'Waffle', 'category_id': 5, 'price': 30000.0, 'image_icon': '🧇', 'is_available': 1, 'stock': 50},
    ];

    // Category 6: Minuman Botol
    final minumanBotolProducts = [
      {'name': 'Air Mineral', 'category_id': 6, 'price': 8000.0, 'image_icon': '💧', 'is_available': 1, 'stock': 50},
      {'name': 'Teh Botol', 'category_id': 6, 'price': 10000.0, 'image_icon': '🧃', 'is_available': 1, 'stock': 50},
      {'name': 'Jus Jeruk', 'category_id': 6, 'price': 15000.0, 'image_icon': '🍊', 'is_available': 1, 'stock': 50},
      {'name': 'Soda', 'category_id': 6, 'price': 12000.0, 'image_icon': '🥤', 'is_available': 1, 'stock': 50},
    ];

    final allProducts = [
      ...kopiProducts,
      ...nonKopiProducts,
      ...makananProducts,
      ...snackProducts,
      ...dessertProducts,
      ...minumanBotolProducts,
    ];

    for (final product in allProducts) {
      await db.insert(DbConstants.tableProducts, product);
    }

    // ─── Coupons ───────────────────────────────────────────────
    final coupons = [
      {
        'code': 'WELCOME10',
        'description': 'Welcome discount 10% for new customers',
        'discount_type': 'percentage',
        'discount_value': 10.0,
        'min_purchase': 50000.0,
        'max_discount': 20000.0,
        'is_active': 1,
        'valid_until': null,
        'usage_limit': 0,
        'usage_count': 0,
      },
      {
        'code': 'HEMAT20',
        'description': 'Hemat 20% untuk pembelian di atas 100rb',
        'discount_type': 'percentage',
        'discount_value': 20.0,
        'min_purchase': 100000.0,
        'max_discount': 50000.0,
        'is_active': 1,
        'valid_until': null,
        'usage_limit': 0,
        'usage_count': 0,
      },
      {
        'code': 'DISKON15K',
        'description': 'Diskon langsung 15rb untuk pembelian min 75rb',
        'discount_type': 'fixed',
        'discount_value': 15000.0,
        'min_purchase': 75000.0,
        'max_discount': null,
        'is_active': 1,
        'valid_until': null,
        'usage_limit': 0,
        'usage_count': 0,
      },
      {
        'code': 'KOPI5K',
        'description': 'Diskon 5rb untuk pecinta kopi',
        'discount_type': 'fixed',
        'discount_value': 5000.0,
        'min_purchase': 25000.0,
        'max_discount': null,
        'is_active': 1,
        'valid_until': null,
        'usage_limit': 0,
        'usage_count': 0,
      },
    ];

    for (final coupon in coupons) {
      await db.insert(DbConstants.tableCoupons, coupon);
    }

    // ─── Default Settings ──────────────────────────────────────
    await db.insert(DbConstants.tableSettings, {
      'key': DbConstants.settingTaxPercent,
      'value': '11',
    });
    await db.insert(DbConstants.tableSettings, {
      'key': DbConstants.settingLocale,
      'value': 'id',
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // CRUD Helpers
  // ═══════════════════════════════════════════════════════════════

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table, {String? orderBy}) async {
    final db = await database;
    return await db.query(table, orderBy: orderBy);
  }

  Future<List<Map<String, dynamic>>> queryWhere(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  Future<Map<String, dynamic>?> queryById(String table, int id) async {
    final db = await database;
    final results = await db.query(
      table,
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  Future<int> rawUpdate(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    final db = await database;
    return await db.rawUpdate(sql, arguments);
  }

  Future<void> batchInsert(
    String table,
    List<Map<String, dynamic>> rows,
  ) async {
    final db = await database;
    final batch = db.batch();
    for (final row in rows) {
      batch.insert(table, row);
    }
    await batch.commit(noResult: true);
  }
}
