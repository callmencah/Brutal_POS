import 'package:flutter/widgets.dart';
import 'l10n_id.dart';
import 'l10n_en.dart';

/// Provides localized strings for the app.
///
/// Usage:
/// ```dart
/// final l10n = AppLocalizations.of(context);
/// Text(l10n.get('home'));
/// ```
///
/// The locale can be changed globally via [AppLocalizations.currentLocale].
/// It defaults to 'id' (Indonesian) and will be connected to SettingsCubit later.
class AppLocalizations extends InheritedWidget {
  /// The current global locale. Defaults to Indonesian.
  static String currentLocale = 'id';

  /// The locale for this instance.
  final String locale;

  const AppLocalizations({
    super.key,
    required super.child,
    this.locale = 'id',
  });

  /// Retrieves the nearest [AppLocalizations] from the widget tree.
  /// If no ancestor is found, returns a default instance with the current locale.
  static AppLocalizations of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<AppLocalizations>();
    if (result != null) {
      return result;
    }
    // Fallback: return a new instance using the global locale.
    return AppLocalizations(
      locale: currentLocale,
      child: const SizedBox.shrink(),
    );
  }

  /// The string map for the active locale.
  Map<String, String> get _strings {
    switch (locale) {
      case 'id':
        return l10nId;
      case 'en':
        return l10nEn;
      default:
        return l10nEn; // fallback to English
    }
  }

  /// Gets a localized string by [key]. Falls back to English, then to the key itself.
  String get(String key) {
    return _strings[key] ?? l10nEn[key] ?? key;
  }

  @override
  bool updateShouldNotify(AppLocalizations oldWidget) {
    return locale != oldWidget.locale;
  }

  // ─── Convenience Getters ────────────────────────────────────────

  // Navigation
  String get home => get('home');
  String get products => get('products');
  String get transactions => get('transactions');
  String get more => get('more');
  String get settings => get('settings');

  // Dashboard
  String get salesTotal => get('salesTotal');
  String get todaySales => get('todaySales');
  String get transactionCount => get('transactionCount');
  String get quickActions => get('quickActions');
  String get recentTransactions => get('recentTransactions');
  String get dashboard => get('dashboard');
  String get welcomeBack => get('welcomeBack');
  String get todayOverview => get('todayOverview');
  String get viewAll => get('viewAll');

  // Products
  String get searchProducts => get('searchProducts');
  String get allCategories => get('allCategories');
  String get addToCart => get('addToCart');
  String get outOfStock => get('outOfStock');
  String get productName => get('productName');
  String get productPrice => get('productPrice');
  String get productCategory => get('productCategory');
  String get productStock => get('productStock');
  String get addProduct => get('addProduct');
  String get editProduct => get('editProduct');
  String get deleteProduct => get('deleteProduct');
  String get productAdded => get('productAdded');
  String get productUpdated => get('productUpdated');
  String get productDeleted => get('productDeleted');
  String get noProducts => get('noProducts');
  String get stock => get('stock');

  // Cart
  String get cart => get('cart');
  String get emptyCart => get('emptyCart');
  String get quantity => get('quantity');
  String get subtotal => get('subtotal');
  String get tax => get('tax');
  String get discount => get('discount');
  String get serviceCharge => get('serviceCharge');
  String get totalBeforeRounding => get('totalBeforeRounding');
  String get rounding => get('rounding');
  String get exact => get('exact');
  String get grandTotal => get('grandTotal');
  String get proceedToPayment => get('proceedToPayment');
  String get clearCart => get('clearCart');
  String get addedToCart => get('addedToCart');
  String get removedFromCart => get('removedFromCart');
  String get cartUpdated => get('cartUpdated');
  String get items => get('items');

  // Coupon
  String get couponCode => get('couponCode');
  String get applyCoupon => get('applyCoupon');
  String get removeCoupon => get('removeCoupon');
  String get invalidCoupon => get('invalidCoupon');
  String get couponApplied => get('couponApplied');
  String get expiredCoupon => get('expiredCoupon');
  String get minPurchase => get('minPurchase');
  String get manageCoupons => get('manageCoupons');
  String get addCoupon => get('addCoupon');
  String get discountType => get('discountType');
  String get percentage => get('percentage');
  String get fixedAmount => get('fixedAmount');
  String get maxDiscount => get('maxDiscount');
  String get validUntil => get('validUntil');
  String get usageLimit => get('usageLimit');
  String get active => get('active');
  String get inactive => get('inactive');

  // Payment
  String get payment => get('payment');
  String get paymentMethod => get('paymentMethod');
  String get cash => get('cash');
  String get qris => get('qris');
  String get eWallet => get('eWallet');
  String get card => get('card');
  String get amountPaid => get('amountPaid');
  String get change => get('change');
  String get payNow => get('payNow');
  String get paymentSuccess => get('paymentSuccess');
  String get transactionSaved => get('transactionSaved');
  String get insufficientPayment => get('insufficientPayment');
  String get enterAmount => get('enterAmount');
  String get printReceipt => get('printReceipt');
  String get newTransaction => get('newTransaction');

  // Transactions
  String get transactionHistory => get('transactionHistory');
  String get today => get('today');
  String get thisWeek => get('thisWeek');
  String get thisMonth => get('thisMonth');
  String get all => get('all');
  String get transactionDetail => get('transactionDetail');
  String get noTransactions => get('noTransactions');
  String get transactionId => get('transactionId');
  String get transactionDate => get('transactionDate');
  String get transactionTotal => get('transactionTotal');
  String get transactionItems => get('transactionItems');

  // Customer
  String get customer => get('customer');
  String get addCustomer => get('addCustomer');
  String get customerName => get('customerName');
  String get phoneNumber => get('phoneNumber');
  String get selectCustomer => get('selectCustomer');
  String get noCustomer => get('noCustomer');
  String get customerAdded => get('customerAdded');
  String get customerList => get('customerList');

  // Settings
  String get taxPercentage => get('taxPercentage');
  String get language => get('language');
  String get about => get('about');
  String get general => get('general');
  String get appearance => get('appearance');
  String get dataManagement => get('dataManagement');
  String get exportData => get('exportData');
  String get importData => get('importData');
  String get resetData => get('resetData');
  String get resetDataConfirm => get('resetDataConfirm');
  String get version => get('version');

  // Reports
  String get reports => get('reports');
  String get totalRevenue => get('totalRevenue');
  String get avgOrderValue => get('avgOrderValue');
  String get topProducts => get('topProducts');
  String get thisWeekSales => get('thisWeekSales');
  String get salesChart => get('salesChart');
  String get revenueByCategory => get('revenueByCategory');
  String get dailySales => get('dailySales');

  // Auth
  String get login => get('login');
  String get username => get('username');
  String get password => get('password');
  String get loginButton => get('loginButton');
  String get invalidCredentials => get('invalidCredentials');
  String get logout => get('logout');
  String get logoutConfirm => get('logoutConfirm');

  // General
  String get save => get('save');
  String get cancel => get('cancel');
  String get delete => get('delete');
  String get edit => get('edit');
  String get confirm => get('confirm');
  String get success => get('success');
  String get error => get('error');
  String get loading => get('loading');
  String get noData => get('noData');
  String get search => get('search');
  String get retry => get('retry');
  String get close => get('close');
  String get yes => get('yes');
  String get no => get('no');
  String get ok => get('ok');
  String get back => get('back');
  String get next => get('next');
  String get done => get('done');
  String get required => get('required');
  String get optional => get('optional');
  String get selectDate => get('selectDate');
  String get selectTime => get('selectTime');
  String get total => get('total');
  String get price => get('price');
  String get name => get('name');
  String get description => get('description');
  String get category => get('category');
  String get date => get('date');
  String get amount => get('amount');
  String get status => get('status');
  String get action => get('action');
  String get detail => get('detail');
  String get welcome => get('welcome');
  String get appName => get('appName');

  // Customer Management
  String get manageCustomers => get('manageCustomers');
  String get editCustomer => get('editCustomer');
  String get deleteCustomerConfirm => get('deleteCustomerConfirm');
  String get customerUpdated => get('customerUpdated');
  String get customerDeleted => get('customerDeleted');
  String get noCustomers => get('noCustomers');
  String get searchCustomers => get('searchCustomers');

  // Void Transactions
  String get voidTransaction => get('voidTransaction');
  String get voidReason => get('voidReason');
  String get voidConfirm => get('voidConfirm');
  String get voided => get('voided');
  String get completed => get('completed');
  String get transactionVoided => get('transactionVoided');

  // Receipt
  String get copyReceipt => get('copyReceipt');
  String get receiptCopied => get('receiptCopied');

  // Stock
  String get stockUnlimited => get('stockUnlimited');
  String get lowStock => get('lowStock');
}

