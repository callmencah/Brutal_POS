import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/app_localizations.dart';
import '../bloc/cart_state.dart';

class CartSummary extends StatelessWidget {
  final CartState state;

  const CartSummary({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 3,
          ),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subtotal row
          _SummaryRow(
            label: l10n.subtotal,
            amount: AppConstants.formatCurrency(state.subtotal),
          ),
          const SizedBox(height: 8),

          // Discount row (if coupon applied)
          if (state.appliedCoupon != null) ...[
            _SummaryRow(
              label: l10n.discount,
              labelWidget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${l10n.discount} ',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      border: Border.all(
                        color: AppColors.primary,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      state.appliedCoupon!.code,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              amount: '-${AppConstants.formatCurrency(state.discountAmount)}',
              amountColor: AppColors.success,
            ),
            const SizedBox(height: 8),
          ],

          // Tax row
          _SummaryRow(
            label:
                '${l10n.tax} (${state.taxPercent % 1 == 0 ? state.taxPercent.toStringAsFixed(0) : state.taxPercent.toStringAsFixed(1)}%)',
            amount: AppConstants.formatCurrency(state.taxAmount),
          ),
          if (state.serviceChargeEnabled) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              label:
                  '${l10n.serviceCharge} (${state.serviceChargePercent % 1 == 0 ? state.serviceChargePercent.toStringAsFixed(0) : state.serviceChargePercent.toStringAsFixed(1)}%)',
              amount: AppConstants.formatCurrency(state.serviceChargeAmount),
            ),
          ],
          const SizedBox(height: 12),

          // Divider
          Container(
            height: 3,
            color: AppColors.border,
          ),
          const SizedBox(height: 12),

          // Grand Total row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.grandTotal,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                AppConstants.formatCurrency(state.grandTotal),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final Widget? labelWidget;
  final String amount;
  final Color? amountColor;

  const _SummaryRow({
    required this.label,
    this.labelWidget,
    required this.amount,
    this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        labelWidget ??
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
        Text(
          amount,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: amountColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

