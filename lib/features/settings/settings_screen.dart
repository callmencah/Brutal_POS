import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/router/app_router.dart';
import '../auth/bloc/auth_cubit.dart';
import 'bloc/settings_cubit.dart';
import 'bloc/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the GLOBAL SettingsCubit from app.dart, no local BlocProvider
    return const _SettingsView();
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    Future<void> pickQrisImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null && context.mounted) {
        try {
          final directory = await getApplicationDocumentsDirectory();
          final fileName = 'qris_${DateTime.now().millisecondsSinceEpoch}.png';
          final savedImage = await File(pickedFile.path).copy('${directory.path}/$fileName');
          if (context.mounted) {
            context.read<SettingsCubit>().updateQrisImage(savedImage.path);
          }
        } catch (e) {
          // Fallback to cache path if copy fails
          context.read<SettingsCubit>().updateQrisImage(pickedFile.path);
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          l10n.more.toUpperCase(),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TAX SECTION
                _SectionTitle(l10n.taxPercentage.toUpperCase()),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    border: Border.all(color: AppColors.border, width: 3),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.shadow,
                          offset: Offset(4, 4),
                          blurRadius: 0),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.taxPercentage,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              border:
                                  Border.all(color: AppColors.shadow, width: 2),
                            ),
                            child: Text(
                              '${state.taxPercent.toStringAsFixed(1)}%',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: AppColors.border,
                          thumbColor: AppColors.primary,
                          overlayColor:
                              AppColors.primary.withOpacity(0.2),
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 10),
                        ),
                        child: Slider(
                          value: state.taxPercent,
                          min: 0,
                          max: 30,
                          divisions: 60,
                          onChanged: (value) {
                            context
                                .read<SettingsCubit>()
                                .updateTaxPercent(value);
                          },
                        ),
                      ),
                      Text(
                        '0% - 30%',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // SERVICE CHARGE SECTION
                const _SectionTitle('SERVICE CHARGE'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    border: Border.all(color: AppColors.border, width: 3),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.shadow,
                          offset: Offset(4, 4),
                          blurRadius: 0),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Enable Service Charge',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Apply a service charge to transactions',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: state.serviceChargeEnabled,
                            activeThumbColor: AppColors.primary,
                            inactiveThumbColor: AppColors.textSecondary,
                            inactiveTrackColor: AppColors.border,
                            onChanged: (value) {
                              context.read<SettingsCubit>().toggleServiceCharge();
                            },
                          ),
                        ],
                      ),
                      if (state.serviceChargeEnabled) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Service Charge %',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                border:
                                    Border.all(color: AppColors.shadow, width: 2),
                              ),
                              child: Text(
                                '${state.serviceChargePercent.toStringAsFixed(1)}%',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: AppColors.primary,
                            inactiveTrackColor: AppColors.border,
                            thumbColor: AppColors.primary,
                            overlayColor:
                                AppColors.primary.withOpacity(0.2),
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 10),
                          ),
                          child: Slider(
                            value: state.serviceChargePercent,
                            min: 0,
                            max: 30,
                            divisions: 60,
                            onChanged: (value) {
                              context
                                  .read<SettingsCubit>()
                                  .updateServiceChargePercent(value);
                            },
                          ),
                        ),
                        Text(
                          '0% - 30%',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ROUND UP SECTION
                const _SectionTitle('ROUND UP (Rp 500)'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    border: Border.all(color: AppColors.border, width: 3),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.shadow,
                          offset: Offset(4, 4),
                          blurRadius: 0),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enable Rounding',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Round up total amount to nearest Rp 500',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: state.roundUpEnabled,
                        activeThumbColor: AppColors.primary,
                        inactiveThumbColor: AppColors.textSecondary,
                        inactiveTrackColor: AppColors.border,
                        onChanged: (value) {
                          context.read<SettingsCubit>().toggleRoundUp();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // THEME SECTION
                const _SectionTitle('THEME'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    border: Border.all(color: AppColors.border, width: 3),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.shadow,
                          offset: Offset(4, 4),
                          blurRadius: 0),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              context.read<SettingsCubit>().setThemeMode('light'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: state.themeMode == 'light'
                                  ? AppColors.primary
                                  : AppColors.surface,
                              border: Border.all(
                                color: state.themeMode == 'light'
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: 3,
                              ),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.light_mode_rounded, size: 28),
                                const SizedBox(height: 6),
                                Text(
                                  'Light',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              context.read<SettingsCubit>().setThemeMode('dark'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: state.themeMode == 'dark'
                                  ? AppColors.primary
                                  : AppColors.surface,
                              border: Border.all(
                                color: state.themeMode == 'dark'
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: 3,
                              ),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.dark_mode_rounded, size: 28),
                                const SizedBox(height: 6),
                                Text(
                                  'Dark',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // LANGUAGE SECTION
                _SectionTitle(l10n.language.toUpperCase()),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    border: Border.all(color: AppColors.border, width: 3),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.shadow,
                          offset: Offset(4, 4),
                          blurRadius: 0),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              context.read<SettingsCubit>().setLocale('id'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: state.locale == 'id'
                                  ? AppColors.primary
                                  : AppColors.surface,
                              border: Border.all(
                                color: state.locale == 'id'
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: 3,
                              ),
                            ),
                            child: Column(
                              children: [
                                const Text('🇮🇩',
                                    style: TextStyle(fontSize: 28)),
                                const SizedBox(height: 6),
                                Text(
                                  'Indonesia',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              context.read<SettingsCubit>().setLocale('en'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: state.locale == 'en'
                                  ? AppColors.primary
                                  : AppColors.surface,
                              border: Border.all(
                                color: state.locale == 'en'
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: 3,
                              ),
                            ),
                            child: Column(
                              children: [
                                const Text('🇬🇧',
                                    style: TextStyle(fontSize: 28)),
                                const SizedBox(height: 6),
                                Text(
                                  'English',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // QRIS UPLOAD SECTION
                const _SectionTitle('QRIS PAYMENT'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    border: Border.all(color: AppColors.border, width: 3),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.shadow,
                          offset: Offset(4, 4),
                          blurRadius: 0),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload QRIS Image',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'This image will be shown when customers select QRIS as payment method.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (state.qrisImagePath != null && state.qrisImagePath!.isNotEmpty && File(state.qrisImagePath!).existsSync())
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.shadow, width: 2),
                            image: DecorationImage(
                              image: FileImage(File(state.qrisImagePath!)),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      GestureDetector(
                        onTap: pickQrisImage,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            border: Border.all(color: AppColors.shadow, width: 2),
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.shadow,
                                  offset: Offset(2, 2),
                                  blurRadius: 0),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              state.qrisImagePath == null ? 'UPLOAD IMAGE' : 'CHANGE IMAGE',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // TELEGRAM BACKUP SECTION
                const _SectionTitle('TELEGRAM BACKUP'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    border: Border.all(color: AppColors.border, width: 3),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.shadow,
                          offset: Offset(4, 4),
                          blurRadius: 0),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Enable Auto-Backup',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Automatically send receipts to Telegram bot',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: state.telegramEnabled,
                            activeThumbColor: AppColors.primary,
                            inactiveThumbColor: AppColors.textSecondary,
                            inactiveTrackColor: AppColors.border,
                            onChanged: (value) {
                              context.read<SettingsCubit>().updateTelegramConfig(enabled: value);
                            },
                          ),
                        ],
                      ),
                      if (state.telegramEnabled) ...[
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            _showTelegramConfigDialog(context, state);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              border: Border.all(color: AppColors.border, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                state.telegramToken.isEmpty ? 'CONFIGURE CREDENTIALS' : 'EDIT CREDENTIALS',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // QUICK LINKS
                const _SectionTitle('QUICK LINKS'),
                const SizedBox(height: 8),
                _LinkTile(
                  icon: Icons.inventory_2_rounded,
                  label: l10n.get('manageProducts'),
                  color: AppColors.primary,
                  onTap: () => context.push('/manage-products'),
                ),
                const SizedBox(height: 8),
                _LinkTile(
                  icon: Icons.local_offer_rounded,
                  label: l10n.manageCoupons,
                  color: AppColors.secondary,
                  onTap: () => context.push('/coupons'),
                ),
                const SizedBox(height: 8),
                _LinkTile(
                  icon: Icons.bar_chart_rounded,
                  label: l10n.reports,
                  color: AppColors.success,
                  onTap: () => context.push('/reports'),
                ),
                const SizedBox(height: 8),
                _LinkTile(
                  icon: Icons.people_rounded,
                  label: l10n.manageCustomers,
                  color: const Color(0xFF42A5F5),
                  onTap: () => context.push('/manage-customers'),
                ),
                const SizedBox(height: 24),

                // ABOUT
                _SectionTitle(l10n.about.toUpperCase()),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    border: Border.all(color: AppColors.border, width: 3),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.shadow,
                          offset: Offset(4, 4),
                          blurRadius: 0),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.appName,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Version ${AppConstants.appVersion}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Neo-Brutalist POS System',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // LOGOUT
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (dialogContext) => Dialog(
                        backgroundColor: AppColors.surface,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            border:
                                Border.all(color: AppColors.border, width: 3),
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.shadow,
                                  offset: Offset(6, 6),
                                  blurRadius: 0),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.logout_rounded,
                                  size: 48, color: AppColors.error),
                              const SizedBox(height: 16),
                              Text(
                                l10n.logout.toUpperCase(),
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.logoutConfirm,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          Navigator.of(dialogContext).pop(),
                                      child: Container(
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: AppColors.card,
                                          border: Border.all(
                                              color: AppColors.border,
                                              width: 3),
                                          boxShadow: [
                                            BoxShadow(
                                                color: AppColors.shadow,
                                                offset: Offset(3, 3),
                                                blurRadius: 0),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            l10n.cancel.toUpperCase(),
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(dialogContext).pop();
                                        isAuthenticated = false; // Fix race condition
                                        context.read<AuthCubit>().logout();
                                        context.go('/login');
                                      },
                                      child: Container(
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: AppColors.error,
                                          border: Border.all(
                                              color: AppColors.shadow, width: 3),
                                          boxShadow: [
                                            BoxShadow(
                                                color: AppColors.shadow,
                                                offset: Offset(3, 3),
                                                blurRadius: 0),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            l10n.logout.toUpperCase(),
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      border: Border.all(color: AppColors.shadow, width: 3),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.shadow,
                            offset: Offset(4, 4),
                            blurRadius: 0),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        l10n.logout.toUpperCase(),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showTelegramConfigDialog(BuildContext context, SettingsState state) {
    final tokenCtrl = TextEditingController(text: state.telegramToken);
    final chatCtrl = TextEditingController(text: state.telegramChatId);
    
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border, width: 3),
            boxShadow: [
              BoxShadow(color: AppColors.shadow, offset: Offset(6, 6)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TELEGRAM CONFIG',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tokenCtrl,
                style: GoogleFonts.inter(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Bot Token',
                  hintText: '123456789:ABCdefGHI...',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: chatCtrl,
                style: GoogleFonts.inter(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Chat ID',
                  hintText: 'e.g. -100123456789',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogCtx),
                      child: Text('CANCEL'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<SettingsCubit>().updateTelegramConfig(
                          token: tokenCtrl.text.trim(),
                          chatId: chatCtrl.text.trim(),
                        );
                        Navigator.pop(dialogCtx);
                      },
                      child: Text('SAVE'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 2,
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _LinkTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border.all(color: AppColors.border, width: 3),
          boxShadow: [
            BoxShadow(
                color: AppColors.shadow, offset: Offset(3, 3), blurRadius: 0),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

