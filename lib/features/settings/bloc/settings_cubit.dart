import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/telegram_service.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository repository;

  SettingsCubit({required this.repository}) : super(const SettingsState());

  Future<void> loadSettings() async {
    emit(state.copyWith(isLoading: true));
    try {
      final taxPercent = await repository.getTaxPercent();
      final locale = await repository.getLocale();
      final roundUp = await repository.getRoundUp();
      final serviceChargeEnabled = await repository.getServiceChargeEnabled();
      final serviceChargePercent = await repository.getServiceChargePercent();
      final themeMode = await repository.getThemeMode();
      final qrisImage = await repository.getQrisImagePath();
      final telegramConfig = await TelegramService.getConfig();
      
      isDarkModeNotifier.value = themeMode == 'dark';

      emit(state.copyWith(
        taxPercent: taxPercent,
        locale: locale,
        roundUpEnabled: roundUp,
        serviceChargeEnabled: serviceChargeEnabled,
        serviceChargePercent: serviceChargePercent,
        themeMode: themeMode,
        qrisImagePath: qrisImage,
        telegramEnabled: telegramConfig['enabled'] as bool,
        telegramToken: telegramConfig['token'] as String,
        telegramChatId: telegramConfig['chatId'] as String,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> updateTaxPercent(double value) async {
    await repository.setTaxPercent(value);
    emit(state.copyWith(taxPercent: value));
  }

  Future<void> toggleRoundUp() async {
    final newValue = !state.roundUpEnabled;
    await repository.setRoundUp(newValue);
    emit(state.copyWith(roundUpEnabled: newValue));
  }

  Future<void> toggleLocale() async {
    final newLocale = state.locale == 'id' ? 'en' : 'id';
    await repository.setLocale(newLocale);
    emit(state.copyWith(locale: newLocale));
  }

  Future<void> setLocale(String locale) async {
    await repository.setLocale(locale);
    emit(state.copyWith(locale: locale));
  }

  Future<void> toggleServiceCharge() async {
    final newValue = !state.serviceChargeEnabled;
    await repository.setServiceChargeEnabled(newValue);
    emit(state.copyWith(serviceChargeEnabled: newValue));
  }

  Future<void> updateServiceChargePercent(double value) async {
    await repository.setServiceChargePercent(value);
    emit(state.copyWith(serviceChargePercent: value));
  }

  Future<void> setThemeMode(String mode) async {
    await repository.setThemeMode(mode);
    isDarkModeNotifier.value = mode == 'dark';
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> updateQrisImage(String? path) async {
    if (path != null) {
      await repository.setQrisImagePath(path);
      emit(state.copyWith(qrisImagePath: path));
    } else {
      // Clear QRIS image logic (if needed in the future)
      emit(state.copyWith(clearQrisImage: true));
    }
  }

  Future<void> updateTelegramConfig({bool? enabled, String? token, String? chatId}) async {
    final newEnabled = enabled ?? state.telegramEnabled;
    final newToken = token ?? state.telegramToken;
    final newChatId = chatId ?? state.telegramChatId;

    await TelegramService.saveConfig(
      enabled: newEnabled,
      token: newToken,
      chatId: newChatId,
    );

    emit(state.copyWith(
      telegramEnabled: newEnabled,
      telegramToken: newToken,
      telegramChatId: newChatId,
    ));
  }
}

