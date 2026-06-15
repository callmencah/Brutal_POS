import 'package:intl/intl.dart';

/// App-wide constants and formatting helpers.
class AppConstants {
  AppConstants._();

  /// Default tax percentage (PPN Indonesia = 11%).
  static double defaultTaxPercent = 11.0;

  /// Currency symbol for Indonesian Rupiah.
  static String currencySymbol = 'Rp';

  /// Default locale identifier.
  static String defaultLocale = 'id_ID';

  /// Application name.
  static String appName = 'BRUTAL POS';

  /// Application version.
  static String appVersion = '1.0.0';

  /// Default page size for paginated lists.
  static int defaultPageSize = 20;

  /// Maximum discount percentage allowed.
  static double maxDiscountPercent = 100.0;

  /// Minimum password length.
  static int minPasswordLength = 4;

  /// Date format patterns.
  static String dateFormatShort = 'dd/MM/yyyy';
  static String dateFormatLong = 'dd MMMM yyyy';
  static String dateFormatWithTime = 'dd/MM/yyyy HH:mm';
  static String timeFormat = 'HH:mm';

  // ─── Formatting Helpers ───────────────────────────────────────────

  /// Formats a monetary amount as Indonesian Rupiah.
  ///
  /// Example: `formatCurrency(150000)` → `"Rp 150.000"`
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '$currencySymbol ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Formats a monetary amount compactly (e.g. "Rp 1,5jt").
  static String formatCurrencyCompact(double amount) {
    if (amount >= 1000000000) {
      return '$currencySymbol ${(amount / 1000000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000000) {
      return '$currencySymbol ${(amount / 1000000).toStringAsFixed(1)}jt';
    } else if (amount >= 1000) {
      return '$currencySymbol ${(amount / 1000).toStringAsFixed(0)}rb';
    }
    return formatCurrency(amount);
  }

  /// Formats a [DateTime] using the default format with time.
  ///
  /// Example: `formatDateTime(dt)` → `"25/05/2026 14:30"`
  static String formatDateTime(DateTime dt) {
    final formatter = DateFormat(dateFormatWithTime, defaultLocale);
    return formatter.format(dt);
  }

  /// Formats a [DateTime] as date only.
  ///
  /// Example: `formatDate(dt)` → `"25/05/2026"`
  static String formatDate(DateTime dt) {
    final formatter = DateFormat(dateFormatShort, defaultLocale);
    return formatter.format(dt);
  }

  /// Formats a [DateTime] as a long date.
  ///
  /// Example: `formatDateLong(dt)` → `"25 Mei 2026"`
  static String formatDateLong(DateTime dt) {
    final formatter = DateFormat(dateFormatLong, 'id_ID');
    return formatter.format(dt);
  }

  /// Formats a [DateTime] as time only.
  ///
  /// Example: `formatTime(dt)` → `"14:30"`
  static String formatTime(DateTime dt) {
    final formatter = DateFormat(timeFormat, defaultLocale);
    return formatter.format(dt);
  }

  /// Formats a number with thousand separators.
  ///
  /// Example: `formatNumber(150000)` → `"150.000"`
  static String formatNumber(num value) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(value);
  }

  /// Returns a relative time description.
  ///
  /// Example: "2 jam lalu", "Baru saja"
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) {
      return 'Baru saja';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    } else {
      return formatDate(dateTime);
    }
  }
}

