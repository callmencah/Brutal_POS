import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/constants/app_constants.dart';
import 'core/l10n/app_localizations.dart';
import 'data/repositories/coupon_repository.dart';
import 'data/repositories/customer_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'features/auth/bloc/auth_cubit.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/cart/bloc/cart_cubit.dart';
import 'features/customers/bloc/customer_cubit.dart';
import 'features/settings/bloc/settings_cubit.dart';
import 'features/settings/bloc/settings_state.dart';

class BrutalPosApp extends StatelessWidget {
  const BrutalPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsRepository = SettingsRepository();
    final couponRepository = CouponRepository();
    final customerRepository = CustomerRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(),
        ),
        BlocProvider<SettingsCubit>(
          create: (_) =>
              SettingsCubit(repository: settingsRepository)..loadSettings(),
        ),
        BlocProvider<CartCubit>(
          create: (_) => CartCubit(
            couponRepository: couponRepository,
            settingsRepository: settingsRepository,
          )..init(),
        ),
        BlocProvider<CustomerCubit>(
          create: (_) =>
              CustomerCubit(repository: customerRepository)..loadCustomers(),
        ),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            isAuthenticated = true;
          } else if (state.status == AuthStatus.unauthenticated) {
            isAuthenticated = false;
          }
        },
        child: BlocListener<SettingsCubit, SettingsState>(
          listener: (context, settingsState) {
            final cartCubit = context.read<CartCubit>();
            if (cartCubit.state.taxPercent != settingsState.taxPercent ||
                cartCubit.state.roundUpEnabled != settingsState.roundUpEnabled ||
                cartCubit.state.serviceChargeEnabled != settingsState.serviceChargeEnabled ||
                cartCubit.state.serviceChargePercent != settingsState.serviceChargePercent) {
              cartCubit.init();
            }
          },
          child: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, settingsState) {
              // Update the global locale for AppLocalizations and Intl
              final localeStr = settingsState.locale;
              AppLocalizations.currentLocale = localeStr;
              
              final intlLocale = localeStr == 'id' ? 'id_ID' : 'en_US';
              Intl.defaultLocale = intlLocale;
              AppConstants.defaultLocale = intlLocale;

              return AppLocalizations(
                locale: localeStr,
                child: MaterialApp.router(
                  key: ValueKey('${settingsState.themeMode}_$localeStr'),
                  title: 'BRUTAL POS',
                  debugShowCheckedModeBanner: false,
                  locale: Locale(localeStr),
                  supportedLocales: const [
                    Locale('id'),
                    Locale('en'),
                  ],
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  theme: settingsState.themeMode == 'light' 
                      ? AppTheme.lightTheme 
                      : AppTheme.darkTheme,
                  routerConfig: appRouter,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

