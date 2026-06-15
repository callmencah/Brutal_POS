import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/app_localizations.dart';

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    Theme.of(context); // Listen to theme changes
    final l10n = AppLocalizations.of(context);
    final actions = [
      _QuickAction(
        icon: Icons.point_of_sale_rounded,
        label: 'POS',
        color: AppColors.primary,
        route: '/pos',
        isTab: true,
      ),
      _QuickAction(
        icon: Icons.local_offer_rounded,
        label: l10n.get('manageCoupons'),
        color: AppColors.secondary,
        route: '/coupons',
        isTab: false,
      ),
      _QuickAction(
        icon: Icons.bar_chart_rounded,
        label: l10n.reports,
        color: AppColors.success,
        route: '/reports',
        isTab: false,
      ),
      _QuickAction(
        icon: Icons.settings_rounded,
        label: l10n.settings,
        color: AppColors.textPrimary,
        route: '/more',
        isTab: true,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: actions.map((action) {
        return _QuickActionItem(action: action);
      }).toList(),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final String route;
  final bool isTab;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
    this.isTab = false,
  });
}

class _QuickActionItem extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionItem({required this.action});

  @override
  Widget build(BuildContext context) {
    Theme.of(context); // Listen to theme changes
    return Material(
      color: AppColors.card,
      child: InkWell(
        onTap: () {
          if (action.isTab) {
            context.go(action.route);
          } else {
            context.push(action.route);
          }
        },
        splashColor: action.color.withOpacity(0.2),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            border: Border.all(color: AppColors.border, width: 3),
            boxShadow: [
              BoxShadow(
                  color: AppColors.shadow, offset: Offset(4, 4), blurRadius: 0),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(action.icon, size: 32, color: action.color),
              const SizedBox(height: 8),
              Text(
                action.label.toUpperCase(),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

