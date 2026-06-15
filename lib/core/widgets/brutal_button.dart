import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/brutalist_decorations.dart';

/// Button variant types.
enum BrutalButtonVariant {
  primary,
  secondary,
  danger,
}

/// A Neo-Brutalist styled button with hard shadow and press animation.
class BrutalButton extends StatefulWidget {
  /// The button label text, displayed in bold uppercase.
  final String text;

  /// Callback when the button is pressed.
  final VoidCallback? onPressed;

  /// Optional icon displayed before the text.
  final IconData? icon;

  /// The visual variant of the button.
  final BrutalButtonVariant variant;

  /// Whether the button should stretch to full width.
  final bool fullWidth;

  /// Whether to show a loading indicator instead of text.
  final bool isLoading;

  /// Custom height (default 56).
  final double height;

  /// Custom font size.
  final double? fontSize;

  const BrutalButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.variant = BrutalButtonVariant.primary,
    this.fullWidth = true,
    this.isLoading = false,
    this.height = 56,
    this.fontSize,
  });

  /// Named constructor for primary variant.
  const BrutalButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.fullWidth = true,
    this.isLoading = false,
    this.height = 56,
    this.fontSize,
  }) : variant = BrutalButtonVariant.primary;

  /// Named constructor for secondary variant.
  const BrutalButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.fullWidth = true,
    this.isLoading = false,
    this.height = 56,
    this.fontSize,
  }) : variant = BrutalButtonVariant.secondary;

  /// Named constructor for danger variant.
  const BrutalButton.danger({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.fullWidth = true,
    this.isLoading = false,
    this.height = 56,
    this.fontSize,
  }) : variant = BrutalButtonVariant.danger;

  @override
  State<BrutalButton> createState() => _BrutalButtonState();
}

class _BrutalButtonState extends State<BrutalButton> {
  bool _isPressed = false;

  Color get _backgroundColor {
    switch (widget.variant) {
      case BrutalButtonVariant.primary:
        return AppColors.primary;
      case BrutalButtonVariant.secondary:
        return AppColors.surface;
      case BrutalButtonVariant.danger:
        return AppColors.error;
    }
  }

  Color get _borderColor {
    switch (widget.variant) {
      case BrutalButtonVariant.primary:
        return AppColors.black;
      case BrutalButtonVariant.secondary:
        return AppColors.primary;
      case BrutalButtonVariant.danger:
        return AppColors.black;
    }
  }

  Color get _textColor {
    switch (widget.variant) {
      case BrutalButtonVariant.primary:
        return AppColors.textPrimary;
      case BrutalButtonVariant.secondary:
        return AppColors.primary;
      case BrutalButtonVariant.danger:
        return AppColors.textPrimary;
    }
  }

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final double shadowOffset = _isPressed && _isEnabled ? 0 : 4;

    return GestureDetector(
      onTapDown: _isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: _isEnabled
          ? (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel:
          _isEnabled ? () => setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(
          _isPressed && _isEnabled ? 4 : 0,
          _isPressed && _isEnabled ? 4 : 0,
          0,
        ),
        constraints: BoxConstraints(
          minHeight: widget.height,
          minWidth: widget.fullWidth ? double.infinity : 0,
        ),
        decoration: BoxDecoration(
          color: _isEnabled
              ? _backgroundColor
              : _backgroundColor.withOpacity(0.5),
          border: Border.all(
            color: _isEnabled
                ? _borderColor
                : _borderColor.withOpacity(0.5),
            width: 3,
          ),
          boxShadow: [
            BrutalistDecorations.hardShadow(
              x: shadowOffset,
              y: shadowOffset,
            ),
          ],
        ),
        child: Material(
          color: AppColors.transparent,
          child: InkWell(
            onTap: _isEnabled ? widget.onPressed : null,
            splashColor: AppColors.textPrimary.withOpacity(0.15),
            highlightColor: AppColors.textPrimary.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: _textColor,
                        ),
                      )
                    : Row(
                        mainAxisSize: widget.fullWidth
                            ? MainAxisSize.max
                            : MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: _textColor,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                          ],
                          Text(
                            widget.text.toUpperCase(),
                            style: AppTextStyles.buttonText.copyWith(
                              color: _textColor,
                              fontSize: widget.fontSize,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

