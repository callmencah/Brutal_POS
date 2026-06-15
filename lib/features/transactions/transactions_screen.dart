import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/refresh_notifier.dart';
import '../../data/repositories/transaction_repository.dart';
import 'bloc/transaction_cubit.dart';
import 'bloc/transaction_state.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionCubit(
        repository: TransactionRepository(),
      )..loadTransactions(),
      child: const _TransactionsView(),
    );
  }
}

class _TransactionsView extends StatefulWidget {
  const _TransactionsView();

  @override
  State<_TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<_TransactionsView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedPaymentMethod = 'All';

  @override
  void initState() {
    super.initState();
    globalRefreshNotifier.addListener(_onRefreshNeeded);
  }

  @override
  void dispose() {
    _searchController.dispose();
    globalRefreshNotifier.removeListener(_onRefreshNeeded);
    super.dispose();
  }

  void _onRefreshNeeded() {
    context.read<TransactionCubit>().loadTransactions();
  }

  IconData _getPaymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.payments_rounded;
      case 'qris':
        return Icons.qr_code_2_rounded;
      case 'e_wallet':
      case 'ewallet':
      case 'e-wallet':
        return Icons.account_balance_wallet_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  Color _getPaymentColor(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return AppColors.success;
      case 'qris':
        return AppColors.secondary;
      case 'e_wallet':
      case 'ewallet':
      case 'e-wallet':
        return const Color(0xFF42A5F5);
      case 'card':
        return const Color(0xFFAB47BC);
      default:
        return AppColors.textSecondary;
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
          l10n.transactions.toUpperCase(),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return BlocBuilder<TransactionCubit, TransactionListState>(
            builder: (context, state) {
              final isLandscape = constraints.maxWidth > 600;
              final listPadding = isLandscape 
                  ? const EdgeInsets.symmetric(horizontal: 64)
                  : const EdgeInsets.symmetric(horizontal: 16);

              return Column(
                children: [
                  // Search & Payment Filter
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              border: Border.all(color: AppColors.border, width: 3),
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
                              decoration: InputDecoration(
                                hintText: '${l10n.search} #TXN...',
                                hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
                                prefixIcon: Icon(Icons.search, color: AppColors.textPrimary),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            border: Border.all(color: AppColors.border, width: 3),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedPaymentMethod,
                              dropdownColor: AppColors.card,
                              icon: Icon(Icons.filter_list, color: AppColors.textPrimary),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              items: ['All', 'Cash', 'QRIS', 'E-WALLET', 'Card']
                                  .map((method) => DropdownMenuItem(
                                        value: method,
                                        child: Text(method.toUpperCase()),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedPaymentMethod = val);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Filter tabs
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                  child: Row(
                    children: TransactionFilter.values.map((filter) {
                      final isSelected = state.filter == filter;
                      final label = switch (filter) {
                        TransactionFilter.today => l10n.today.toUpperCase(),
                        TransactionFilter.thisWeek =>
                          l10n.thisWeek.toUpperCase(),
                        TransactionFilter.thisMonth =>
                          l10n.thisMonth.toUpperCase(),
                        TransactionFilter.all => l10n.all.toUpperCase(),
                      };
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => context
                              .read<TransactionCubit>()
                              .setFilter(filter),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.card,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: 3,
                              ),
                            ),
                            child: Text(
                              label,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Transaction list
              Expanded(
                child: state.status == TransactionListStatus.loading
                    ? Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary))
                    : state.status == TransactionListStatus.error
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline,
                                    size: 48, color: AppColors.error),
                                const SizedBox(height: 12),
                                Text(
                                  state.error ?? l10n.error,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppColors.error,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: () => context
                                      .read<TransactionCubit>()
                                      .refresh(),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      border: Border.all(
                                          color: AppColors.shadow, width: 2),
                                    ),
                                    child: Text(
                                      l10n.retry.toUpperCase(),
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : state.transactions.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.receipt_long_rounded,
                                        size: 56,
                                        color: AppColors.textSecondary
                                            .withOpacity(0.4)),
                                    const SizedBox(height: 16),
                                    Text(
                                      l10n.noTransactions,
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Builder(
                                builder: (context) {
                                  var displayed = state.transactions;
                                  
                                  if (_searchController.text.isNotEmpty) {
                                    final query = _searchController.text.replaceAll('#', '').trim();
                                    displayed = displayed.where((tx) => 
                                      tx.id.toString().padLeft(4, '0').contains(query) || tx.id.toString() == query
                                    ).toList();
                                  }
                                  
                                  if (_selectedPaymentMethod != 'All') {
                                    final filterKey = _selectedPaymentMethod.toLowerCase().replaceAll('-', '').replaceAll('_', '');
                                    displayed = displayed.where((tx) {
                                      final txMethod = tx.paymentMethod.toLowerCase().replaceAll('-', '').replaceAll('_', '');
                                      return txMethod == filterKey;
                                    }).toList();
                                  }

                                  if (displayed.isEmpty) {
                                    return Center(
                                      child: Text(
                                        'No matching transactions found.',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    padding: listPadding,
                                    itemCount: displayed.length,
                                    itemBuilder: (context, index) {
                                      final tx = displayed[index];
                                      final color = _getPaymentColor(tx.paymentMethod);
                                      final isVoid = tx.status == 'voided';
                                      
                                      return GestureDetector(
                                        onTap: () => context.push('/transaction-detail/${tx.id}'),
                                        child: Container(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: isVoid ? AppColors.background : AppColors.card,
                                            border: Border.all(
                                                color: isVoid ? AppColors.error.withOpacity(0.5) : AppColors.border, 
                                                width: 3),
                                            boxShadow: [
                                              BoxShadow(
                                                color: isVoid ? AppColors.error.withOpacity(0.2) : AppColors.shadow,
                                                offset: const Offset(3, 3),
                                                blurRadius: 0,
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 44,
                                                height: 44,
                                                decoration: BoxDecoration(
                                                  color: isVoid ? AppColors.error.withOpacity(0.1) : color.withOpacity(0.15),
                                                  border: Border.all(color: isVoid ? AppColors.error : color, width: 2),
                                                ),
                                                child: Icon(
                                                  isVoid ? Icons.block : _getPaymentIcon(tx.paymentMethod),
                                                  color: isVoid ? AppColors.error : color,
                                                  size: 22,
                                                ),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          '#${tx.id.toString().padLeft(4, '0')}',
                                                          style: GoogleFonts.spaceGrotesk(
                                                            fontSize: 15,
                                                            fontWeight: FontWeight.w700,
                                                            color: isVoid ? AppColors.textSecondary : AppColors.textPrimary,
                                                            decoration: isVoid ? TextDecoration.lineThrough : null,
                                                          ),
                                                        ),
                                                        if (isVoid) ...[
                                                          const SizedBox(width: 8),
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                            decoration: BoxDecoration(
                                                              color: AppColors.error.withOpacity(0.1),
                                                              border: Border.all(color: AppColors.error, width: 1),
                                                            ),
                                                            child: Text(
                                                              'VOID',
                                                              style: GoogleFonts.inter(
                                                                fontSize: 10,
                                                                fontWeight: FontWeight.bold,
                                                                color: AppColors.error,
                                                              ),
                                                            ),
                                                          ),
                                                        ] else if (tx.couponCode != null) ...[
                                                          const SizedBox(width: 8),
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                            decoration: BoxDecoration(
                                                              color: AppColors.secondary.withOpacity(0.2),
                                                              border: Border.all(color: AppColors.secondary, width: 1),
                                                            ),
                                                            child: Text(
                                                              tx.couponCode!,
                                                              style: GoogleFonts.inter(
                                                                fontSize: 10,
                                                                fontWeight: FontWeight.w700,
                                                                color: AppColors.secondary,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      AppConstants.formatDateTime(tx.createdAt),
                                                      style: GoogleFonts.inter(
                                                        fontSize: 13,
                                                        color: AppColors.textSecondary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                AppConstants.formatCurrency(tx.total),
                                                style: GoogleFonts.spaceGrotesk(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w700,
                                                  color: isVoid ? AppColors.textSecondary : AppColors.textPrimary,
                                                  decoration: isVoid ? TextDecoration.lineThrough : null,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Icon(
                                                Icons.chevron_right_rounded,
                                                color: AppColors.textSecondary,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                },
                                  );
                                },
                              ),
              ),
              ],
              );
            },
          );
        },
      ),
    );
  }
}

