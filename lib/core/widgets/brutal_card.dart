import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/brutalist_decorations.dart';

/// A Neo-Brutalist styled card container with hard shadow and thick border.
class BrutalCard extends StatelessWidget {
  /// The child widget to display inside the card.
  final Widget child;

  /// Optional tap callback. When provided, adds an ink splash effect.
  final VoidCallback? onTap;

  /// Padding inside the card.
  final EdgeInsetsGeometry padding;

  /// Background color override.
  final Color? color;

  /// Border color override.
  final Color? borderColor;

  /// Border width.
  final double borderWidth;

  /// Whether to show the hard shadow.
  final bool showShadow;

  const BrutalCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.borderColor,
    this.borderWidth = 3,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: showShadow
          ? BrutalistDecorations.brutalBox(
              color: color,
              borderColor: borderColor,
              borderWidth: borderWidth,
            )
          : BrutalistDecorations.brutalBoxFlat(
              color: color,
              borderColor: borderColor,
              borderWidth: borderWidth,
            ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: onTap != null
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.transparent,
          highlightColor: onTap != null
              ? AppColors.primary.withOpacity(0.05)
              : AppColors.transparent,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

