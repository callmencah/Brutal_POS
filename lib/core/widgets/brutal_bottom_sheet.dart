import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shows a Neo-Brutalist styled modal bottom sheet.
///
/// Features a dark background, thick orange top border, a handle bar,
/// and an optional title.
Future<T?> showBrutalBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  bool isDismissible = true,
  bool enableDrag = true,
  bool isScrollControlled = true,
  double? maxHeight,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    isScrollControlled: isScrollControlled,
    backgroundColor: AppColors.transparent,
    barrierColor: AppColors.black.withOpacity(0.6),
    builder: (context) {
      return _BrutalBottomSheetContent(
        title: title,
        maxHeight: maxHeight,
        child: child,
      );
    },
  );
}

class _BrutalBottomSheetContent extends StatelessWidget {
  final Widget child;
  final String? title;
  final double? maxHeight;

  const _BrutalBottomSheetContent({
    required this.child,
    this.title,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final effectiveMaxHeight = maxHeight ?? screenHeight * 0.85;

    return Container(
      constraints: BoxConstraints(
        maxHeight: effectiveMaxHeight,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.primary,
            width: 4,
          ),
          left: BorderSide(
            color: AppColors.border,
            width: 3,
          ),
          right: BorderSide(
            color: AppColors.border,
            width: 3,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          // Title
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Text(
                title!,
                style: AppTextStyles.titleLarge,
              ),
            ),
          // Content
          Flexible(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows a confirmation bottom sheet with a message and confirm/cancel buttons.
Future<bool> showBrutalConfirmSheet({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'CONFIRM',
  String cancelText = 'CANCEL',
  Color? confirmColor,
}) async {
  final result = await showBrutalBottomSheet<bool>(
    context: context,
    title: title,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _SheetButton(
                text: cancelText,
                onTap: () => Navigator.of(context).pop(false),
                backgroundColor: AppColors.card,
                textColor: AppColors.textPrimary,
                borderColor: AppColors.border,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SheetButton(
                text: confirmText,
                onTap: () => Navigator.of(context).pop(true),
                backgroundColor: confirmColor ?? AppColors.primary,
                textColor: AppColors.textPrimary,
                borderColor: AppColors.black,
              ),
            ),
          ],
        ),
      ],
    ),
  );
  return result ?? false;
}

class _SheetButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const _SheetButton({
    required this.text,
    required this.onTap,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: borderColor,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              offset: const Offset(3, 3),
              color: AppColors.black,
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: AppTextStyles.buttonText.copyWith(
              color: textColor,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

