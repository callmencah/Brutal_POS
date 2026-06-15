import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/transaction.dart' as model;
import '../../../core/l10n/app_localizations.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<model.Transaction> transactions;

  const RecentTransactionsList({super.key, required this.transactions});

  IconData _getPaymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.payments_rounded;
      case 'qris':
        return Icons.qr_code_2_rounded;
      case 'e-wallet':
      case 'ewallet':
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
      case 'e-wallet':
      case 'ewallet':
        return const Color(0xFF42A5F5);
      case 'card':
        return const Color(0xFFAB47BC);
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                size: 48,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context).noTransactions,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final color = _getPaymentColor(tx.paymentMethod);
        final isVoid = tx.status == 'voided';
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: isVoid ? AppColors.error.withOpacity(0.5) : AppColors.border, width: 2),
            ),
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
                  size: 22
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
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
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
            ],
          ),
        );
      },
    );
  }
}

