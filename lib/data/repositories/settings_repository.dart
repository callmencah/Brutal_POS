import '../database/database_helper.dart';
import '../database/db_constants.dart';

class SettingsRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<double> getTaxPercent() async {
    final value = await getSetting(DbConstants.settingTaxPercent);
    return double.tryParse(value ?? '11') ?? 11.0;
  }

  Future<void> setTaxPercent(double value) async {
    await setSetting(DbConstants.settingTaxPercent, value.toString());
  }

  Future<String> getLocale() async {
    final value = await getSetting(DbConstants.settingLocale);
    return value ?? 'id';
  }

  Future<void> setLocale(String locale) async {
    await setSetting(DbConstants.settingLocale, locale);
  }

  Future<bool> getRoundUp() async {
    final value = await getSetting(DbConstants.settingRoundUp);
    return value == 'true';
  }

  Future<void> setRoundUp(bool value) async {
    await setSetting(DbConstants.settingRoundUp, value.toString());
  }

  Future<bool> getServiceChargeEnabled() async {
    final value = await getSetting(DbConstants.settingServiceCharge);
    return value == 'true';
  }

  Future<void> setServiceChargeEnabled(bool value) async {
    await setSetting(DbConstants.settingServiceCharge, value.toString());
  }

  Future<double> getServiceChargePercent() async {
    final value = await getSetting(DbConstants.settingServiceChargePercent);
    return double.tryParse(value ?? '5') ?? 5.0; // default 5%
  }

  Future<void> setServiceChargePercent(double value) async {
    await setSetting(DbConstants.settingServiceChargePercent, value.toString());
  }

  Future<String> getThemeMode() async {
    final value = await getSetting(DbConstants.settingThemeMode);
    return value ?? 'dark';
  }

  Future<void> setThemeMode(String mode) async {
    await setSetting(DbConstants.settingThemeMode, mode);
  }

  Future<String?> getQrisImagePath() async {
    return await getSetting(DbConstants.settingQrisImage);
  }

  Future<void> setQrisImagePath(String path) async {
    await setSetting(DbConstants.settingQrisImage, path);
  }

  Future<String> getStoreName() async {
    final value = await getSetting(DbConstants.settingStoreName);
    return value ?? 'BRUTAL POS';
  }

  Future<void> setStoreName(String name) async {
    await setSetting(DbConstants.settingStoreName, name);
  }

  Future<String> getStoreAddress() async {
    final value = await getSetting(DbConstants.settingStoreAddress);
    return value ?? '';
  }

  Future<void> setStoreAddress(String address) async {
    await setSetting(DbConstants.settingStoreAddress, address);
  }

  Future<String?> getSetting(String key) async {
    final maps = await _dbHelper.queryWhere(
      DbConstants.tableSettings,
      where: '${DbConstants.colKey} = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return maps.first[DbConstants.colValue] as String?;
  }

  Future<void> setSetting(String key, String value) async {
    await _dbHelper.insert(
      DbConstants.tableSettings,
      {DbConstants.colKey: key, DbConstants.colValue: value},
    );
  }
}
