import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/app_localizations.dart';

class SalesSummaryCard extends StatelessWidget {
  final double totalSales;
  final int transactionCount;
  final int voidCount;

  const SalesSummaryCard({
    super.key,
    required this.totalSales,
    required this.transactionCount,
    this.voidCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final average =
        transactionCount > 0 ? totalSales / transactionCount : 0.0;

    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 3),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, offset: Offset(4, 4), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.todaySales.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppConstants.formatCurrency(totalSales),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatBadge(
                icon: Icons.receipt_long,
                label: '$transactionCount txn',
                color: AppColors.secondary,
              ),
              if (voidCount > 0)
                _StatBadge(
                  icon: Icons.block,
                  label: '$voidCount void',
                  color: AppColors.error,
                ),
              _StatBadge(
                icon: Icons.trending_up,
                label: 'Avg ${AppConstants.formatCurrency(average)}',
                color: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

