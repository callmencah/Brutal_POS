import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Provides static helper methods for creating Neo-Brutalist visual decorations.
class BrutalistDecorations {
  BrutalistDecorations._();

  /// Creates a box decoration with a hard shadow and thick border.
  static BoxDecoration brutalBox({
    Color? color,
    Color? borderColor,
    double borderWidth = 3,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.card,
      border: Border.all(
        color: borderColor ?? AppColors.border,
        width: borderWidth,
      ),
      boxShadow: [
        hardShadow(),
      ],
    );
  }

  /// Creates a box decoration with an orange (primary) border highlight.
  static BoxDecoration brutalBoxSelected({
    Color? color,
    double borderWidth = 3,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.card,
      border: Border.all(
        color: AppColors.primary,
        width: borderWidth,
      ),
      boxShadow: [
        hardShadow(),
      ],
    );
  }

  /// Creates a hard, offset drop shadow with no blur.
  static BoxShadow hardShadow({
    double x = 4,
    double y = 4,
    Color? color,
  }) {
    return BoxShadow(
      offset: Offset(x, y),
      color: color ?? AppColors.shadow,
      blurRadius: 0,
      spreadRadius: 0,
    );
  }

  /// Creates a thick border using the app's border styling.
  static Border brutalBorder({
    Color? color,
    double width = 3,
  }) {
    return Border.all(
      color: color ?? AppColors.border,
      width: width,
    );
  }

  /// Creates a box decoration with no shadow (flat).
  static BoxDecoration brutalBoxFlat({
    Color? color,
    Color? borderColor,
    double borderWidth = 3,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.card,
      border: Border.all(
        color: borderColor ?? AppColors.border,
        width: borderWidth,
      ),
    );
  }

  /// Creates a box decoration for a pressed/active state (shadow removed).
  static BoxDecoration brutalBoxPressed({
    Color? color,
    Color? borderColor,
    double borderWidth = 3,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.card,
      border: Border.all(
        color: borderColor ?? AppColors.border,
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          offset: const Offset(0, 0),
          color: AppColors.shadow,
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ],
    );
  }

  /// Creates an input-style decoration with thick border.
  static BoxDecoration brutalInput({
    bool focused = false,
    bool hasError = false,
  }) {
    Color borderColor;
    if (hasError) {
      borderColor = AppColors.error;
    } else if (focused) {
      borderColor = AppColors.primary;
    } else {
      borderColor = AppColors.border;
    }

    return BoxDecoration(
      color: AppColors.surface,
      border: Border.all(
        color: borderColor,
        width: 3,
      ),
    );
  }

  /// Top-only border for bottom sheets and dividers.
  static Border brutalTopBorder({
    Color? color,
    double width = 3,
  }) {
    return Border(
      top: BorderSide(
        color: color ?? AppColors.primary,
        width: width,
      ),
    );
  }

  /// Bottom-only border.
  static Border brutalBottomBorder({
    Color? color,
    double width = 2,
  }) {
    return Border(
      bottom: BorderSide(
        color: color ?? AppColors.border,
        width: width,
      ),
    );
  }
}

