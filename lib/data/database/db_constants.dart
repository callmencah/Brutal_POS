class DbConstants {
  DbConstants._();

  static String databaseName = 'brutalist_pos.db';
  static int databaseVersion = 4;

  // ─── Table Names ───────────────────────────────────────────────
  static String tableCategories = 'categories';
  static String tableProducts = 'products';
  static String tableCustomers = 'customers';
  static String tableCoupons = 'coupons';
  static String tableTransactions = 'transactions';
  static String tableTransactionItems = 'transaction_items';
  static String tableSettings = 'settings';

  // ─── Categories Columns ────────────────────────────────────────
  static String colId = 'id';
  static String colNameId = 'name_id';
  static String colNameEn = 'name_en';
  static String colIcon = 'icon';

  // ─── Products Columns ─────────────────────────────────────────
  static String colName = 'name';
  static String colCategoryId = 'category_id';
  static String colPrice = 'price';
  static String colImageIcon = 'image_icon';
  static String colImagePath = 'image_path';
  static String colIsAvailable = 'is_available';
  static String colStock = 'stock';

  // ─── Customers Columns ────────────────────────────────────────
  static String colPhone = 'phone';
  static String colCreatedAt = 'created_at';

  // ─── Coupons Columns ──────────────────────────────────────────
  static String colCode = 'code';
  static String colDescription = 'description';
  static String colDiscountType = 'discount_type';
  static String colDiscountValue = 'discount_value';
  static String colMinPurchase = 'min_purchase';
  static String colMaxDiscount = 'max_discount';
  static String colIsActive = 'is_active';
  static String colValidUntil = 'valid_until';
  static String colUsageLimit = 'usage_limit';
  static String colUsageCount = 'usage_count';

  // ─── Transactions Columns ─────────────────────────────────────
  static String colCustomerId = 'customer_id';
  static String colSubtotal = 'subtotal';
  static String colTaxPercent = 'tax_percent';
  static String colTaxAmount = 'tax_amount';
  static String colDiscountAmount = 'discount_amount';
  static String colCouponCode = 'coupon_code';
  static String colTotal = 'total';
  static String colPaymentMethod = 'payment_method';
  static String colAmountPaid = 'amount_paid';
  static String colChangeAmount = 'change_amount';
  static String colStatus = 'status';
  static String colVoidedAt = 'voided_at';
  static String colVoidReason = 'void_reason';
  static String colServiceChargeAmount = 'service_charge_amount';
  static String colRoundUpAmount = 'round_up_amount';

  // ─── Transaction Items Columns ────────────────────────────────
  static String colTransactionId = 'transaction_id';
  static String colProductId = 'product_id';
  static String colProductName = 'product_name';
  static String colQuantity = 'quantity';
  static String colUnitPrice = 'unit_price';

  // ─── Settings Columns ─────────────────────────────────────────
  static String colKey = 'key';
  static String colValue = 'value';

  // ─── Settings Keys ────────────────────────────────────────────
  static String settingTaxPercent = 'tax_percent';
  static String settingLocale = 'locale';
  static String settingRoundUp = 'round_up_500';
  static String settingServiceCharge = 'service_charge';
  static String settingServiceChargePercent = 'service_charge_percent';
  static String settingThemeMode = 'theme_mode';
  static String settingQrisImage = 'qris_image_path';
  static String settingStoreName = 'store_name';
  static String settingStoreAddress = 'store_address';
}

