import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A small Neo-Brutalist pill/badge for displaying counts or labels.
///
/// Typically used as a cart count overlay on icons.
class BrutalBadge extends StatelessWidget {
  /// The text or count to display.
  final String text;

  /// Background color (defaults to primary orange).
  final Color? color;

  /// Text color (defaults to black).
  final Color? textColor;

  /// Minimum width of the badge.
  final double minWidth;

  /// Height of the badge.
  final double height;

  /// Whether to show a border.
  final bool showBorder;

  const BrutalBadge({
    super.key,
    required this.text,
    this.color,
    this.textColor,
    this.minWidth = 22,
    this.height = 22,
    this.showBorder = true,
  });

  /// Convenience constructor for numeric count badges.
  factory BrutalBadge.count(
    int count, {
    Key? key,
    Color? color,
  }) {
    return BrutalBadge(
      key: key,
      text: count > 99 ? '99+' : count.toString(),
      color: color,
    );
  }

  /// Convenience constructor for a yellow badge variant.
  factory BrutalBadge.yellow(
    String text, {
    Key? key,
  }) {
    return BrutalBadge(
      key: key,
      text: text,
      color: AppColors.secondary,
      textColor: AppColors.black,
    );
  }

  /// Convenience constructor for a success/green badge.
  factory BrutalBadge.success(
    String text, {
    Key? key,
  }) {
    return BrutalBadge(
      key: key,
      text: text,
      color: AppColors.success,
      textColor: AppColors.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minWidth: minWidth,
        minHeight: height,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color ?? AppColors.primary,
        border: showBorder
            ? Border.all(
                color: AppColors.black,
                width: 2,
              )
            : null,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Center(
        widthFactor: 1,
        child: Text(
          text,
          style: AppTextStyles.badge.copyWith(
            color: textColor ?? AppColors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// A wrapper widget that positions a [BrutalBadge] on top of a child widget.
///
/// Useful for adding a count badge on top of an icon (e.g. cart icon).
class BrutalBadgeOverlay extends StatelessWidget {
  /// The main child widget (e.g. an icon).
  final Widget child;

  /// The count to show on the badge. If 0, no badge is displayed.
  final int count;

  /// Badge color override.
  final Color? badgeColor;

  /// Position offset from the top-right corner.
  final double top;
  final double right;

  const BrutalBadgeOverlay({
    super.key,
    required this.child,
    required this.count,
    this.badgeColor,
    this.top = -6,
    this.right = -10,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            top: top,
            right: right,
            child: BrutalBadge.count(
              count,
              color: badgeColor,
            ),
          ),
      ],
    );
  }
}

