import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/products/products_screen.dart';
import '../../features/transactions/transactions_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/cart/cart_screen.dart';
import '../../features/payment/payment_screen.dart';
import '../../features/transactions/transaction_detail_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/coupons/coupon_manage_screen.dart';
import '../../features/customers/customer_list_screen.dart';
import '../../features/products/product_manage_screen.dart';
import '../../features/shell/main_shell.dart';

/// Global navigator key for root navigation.
final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

/// Whether the user is currently authenticated.
bool isAuthenticated = false;

/// The app's route configuration using GoRouter.
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  debugLogDiagnostics: false,
  redirect: (BuildContext context, GoRouterState state) {
    final currentPath = state.matchedLocation;

    // Allow splash screen always
    if (currentPath == '/splash') {
      return null;
    }

    // If not authenticated, redirect to login (unless already on login)
    if (!isAuthenticated && currentPath != '/login') {
      return '/login';
    }

    // If authenticated and on login, redirect to home
    if (isAuthenticated && currentPath == '/login') {
      return '/home';
    }

    return null;
  },
  routes: [
    // Splash
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // Login
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    // Main shell with bottom navigation using StatefulShellRoute
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: HomeScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/pos',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProductsScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/manage-products',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProductManageScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/transactions',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: TransactionsScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/more',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: SettingsScreen(),
              ),
            ),
          ],
        ),
      ],
    ),

    // Full-screen routes (outside shell)
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: '/payment',
      builder: (context, state) => const PaymentScreen(),
    ),
    GoRoute(
      path: '/transaction-detail/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return TransactionDetailScreen(transactionId: id);
      },
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const ReportsScreen(),
    ),
    GoRoute(
      path: '/coupons',
      builder: (context, state) => const CouponManageScreen(),
    ),
    GoRoute(
      path: '/manage-customers',
      builder: (context, state) => const CustomerListScreen(),
    ),
  ],
);

/// Helper extension for easier navigation.
extension AppRouterExtension on BuildContext {
  void goHome() => go('/home');
  void goPos() => go('/pos');
  void goTransactions() => go('/transactions');
  void goMore() => go('/more');
  void goCart() => push('/cart');
  void goPayment() => push('/payment');
  void goReports() => push('/reports');
  void goCoupons() => push('/coupons');
  void goManageCustomers() => push('/manage-customers');
  void goLogin() => go('/login');
  void goTransactionDetail(String id) => push('/transaction-detail/$id');
}

