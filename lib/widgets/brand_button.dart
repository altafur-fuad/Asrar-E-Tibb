import 'package:flutter/material.dart';
import '../app_colors.dart';

enum BrandButtonVariant {
  primary,
  secondary,
  outline,
  danger,
}

/// A modern, accessible button styled with Asrar-e-Tibb brand tokens.
class BrandButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final BrandButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double height;
  final EdgeInsetsGeometry? padding;

  const BrandButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = BrandButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height = 48.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = onPressed != null && !isLoading;

    Color bg;
    Color fg;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case BrandButtonVariant.primary:
        bg = isDark ? AppColors.brandFresh : AppColors.brandGreen;
        fg = Colors.white;
        break;
      case BrandButtonVariant.secondary:
        bg = isDark ? AppColors.softSageDark : AppColors.softSage;
        fg = isDark ? AppColors.brandFresh : AppColors.brandForest;
        break;
      case BrandButtonVariant.outline:
        bg = Colors.transparent;
        fg = isDark ? AppColors.brandFresh : AppColors.brandForest;
        borderSide = BorderSide(
          color: isDark ? AppColors.brandFresh : AppColors.brandForest,
          width: 1.5,
        );
        break;
      case BrandButtonVariant.danger:
        bg = AppColors.danger;
        fg = Colors.white;
        break;
    }

    Widget content;
    if (isLoading) {
      content = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(fg),
        ),
      );
    } else if (icon != null) {
      content = Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      );
    } else {
      content = Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: fg,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      );
    }

    final buttonWidget = Material(
      color: isEnabled ? bg : bg.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: borderSide,
      ),
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: height,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          child: content,
        ),
      ),
    );

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: buttonWidget,
      );
    }

    return buttonWidget;
  }
}
