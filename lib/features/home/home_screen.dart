import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/l10n/app_localizations.dart';

import '../../data/repositories/transaction_repository.dart';
import '../../data/models/transaction.dart' as model;
import '../../core/utils/refresh_notifier.dart';
import 'widgets/sales_summary_card.dart';
import 'widgets/quick_action_grid.dart';
import 'widgets/recent_transactions_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TransactionRepository _transactionRepo = TransactionRepository();
  double _totalSales = 0;
  int _transactionCount = 0;
  List<model.Transaction> _recentTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    globalRefreshNotifier.addListener(_loadData);
  }

  @override
  void dispose() {
    globalRefreshNotifier.removeListener(_loadData);
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final summary = await _transactionRepo.getTodaySummary();
      final recent = await _transactionRepo.getTransactionsToday();

      if (mounted) {
        setState(() {
          _totalSales = summary['total'] ?? 0.0;
          _transactionCount = summary['count'] ?? 0;
          _recentTransactions = recent.take(5).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'BRUTAL POS',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: _loadData,
              icon: Icon(Icons.refresh_rounded, color: AppColors.primary),
            ),
          ),
        ],
      ),
        body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isLandscape = constraints.maxWidth > 600;

                  if (isLandscape) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SalesSummaryCard(
                                  totalSales: _totalSales,
                                  transactionCount: _transactionCount,
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  l10n.quickActions.toUpperCase(),
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                QuickActionGrid(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.recentTransactions.toUpperCase(),
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                RecentTransactionsList(
                                    transactions: _recentTransactions),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SalesSummaryCard(
                          totalSales: _totalSales,
                          transactionCount: _transactionCount,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'QUICK ACTIONS',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        QuickActionGrid(),
                        const SizedBox(height: 24),
                        Text(
                          'RECENT TRANSACTIONS',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        RecentTransactionsList(
                            transactions: _recentTransactions),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}

