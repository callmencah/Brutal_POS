import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final double taxPercent;
  final String locale;
  final bool isLoading;
  final bool roundUpEnabled;
  final bool serviceChargeEnabled;
  final double serviceChargePercent;
  final String themeMode;
  final String? qrisImagePath;
  final bool telegramEnabled;
  final String telegramToken;
  final String telegramChatId;

  const SettingsState({
    this.taxPercent = 11.0,
    this.locale = 'id',
    this.isLoading = false,
    this.roundUpEnabled = false,
    this.serviceChargeEnabled = false,
    this.serviceChargePercent = 5.0,
    this.themeMode = 'dark',
    this.qrisImagePath,
    this.telegramEnabled = false,
    this.telegramToken = '',
    this.telegramChatId = '',
  });

  SettingsState copyWith({
    double? taxPercent,
    String? locale,
    bool? isLoading,
    bool? roundUpEnabled,
    bool? serviceChargeEnabled,
    double? serviceChargePercent,
    String? themeMode,
    String? qrisImagePath,
    bool clearQrisImage = false,
    bool? telegramEnabled,
    String? telegramToken,
    String? telegramChatId,
  }) {
    return SettingsState(
      taxPercent: taxPercent ?? this.taxPercent,
      locale: locale ?? this.locale,
      isLoading: isLoading ?? this.isLoading,
      roundUpEnabled: roundUpEnabled ?? this.roundUpEnabled,
      serviceChargeEnabled: serviceChargeEnabled ?? this.serviceChargeEnabled,
      serviceChargePercent: serviceChargePercent ?? this.serviceChargePercent,
      themeMode: themeMode ?? this.themeMode,
      qrisImagePath: clearQrisImage ? null : (qrisImagePath ?? this.qrisImagePath),
      telegramEnabled: telegramEnabled ?? this.telegramEnabled,
      telegramToken: telegramToken ?? this.telegramToken,
      telegramChatId: telegramChatId ?? this.telegramChatId,
    );
  }

  @override
  List<Object?> get props => [
    taxPercent, locale, isLoading, roundUpEnabled, 
    serviceChargeEnabled, serviceChargePercent, themeMode, qrisImagePath,
    telegramEnabled, telegramToken, telegramChatId
  ];
}

