import 'package:flutter/material.dart';
import '../app_colors.dart';

enum StatusPillVariant {
  sage,
  fresh,
  amber,
  danger,
  neutral,
}

/// A compact, accessible badge/chip for dosage forms, verification status, and tags.
class StatusPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final StatusPillVariant variant;
  final VoidCallback? onTap;
  final bool isSmall;

  const StatusPill({
    super.key,
    required this.label,
    this.icon,
    this.variant = StatusPillVariant.sage,
    this.onTap,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;
    BoxBorder? border;

    switch (variant) {
      case StatusPillVariant.sage:
        bg = isDark ? AppColors.softSageDark : AppColors.softSage;
        fg = isDark ? AppColors.brandFresh : AppColors.brandForest;
        border = Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderSubtle,
          width: 0.8,
        );
        break;
      case StatusPillVariant.fresh:
        bg = isDark
            ? AppColors.brandFresh.withValues(alpha: 0.2)
            : AppColors.successSoft;
        fg = isDark ? AppColors.brandFresh : AppColors.success;
        border = Border.all(
          color: fg.withValues(alpha: 0.3),
          width: 0.8,
        );
        break;
      case StatusPillVariant.amber:
        bg = isDark
            ? AppColors.accentAmber.withValues(alpha: 0.2)
            : AppColors.accentAmberSoft;
        fg = isDark ? AppColors.accentAmber : AppColors.warning;
        border = Border.all(
          color: fg.withValues(alpha: 0.3),
          width: 0.8,
        );
        break;
      case StatusPillVariant.danger:
        bg = isDark
            ? AppColors.danger.withValues(alpha: 0.2)
            : AppColors.dangerSoft;
        fg = AppColors.danger;
        border = Border.all(
          color: fg.withValues(alpha: 0.3),
          width: 0.8,
        );
        break;
      case StatusPillVariant.neutral:
        bg = isDark ? Colors.grey.shade800 : Colors.grey.shade100;
        fg = isDark ? Colors.grey.shade300 : Colors.grey.shade700;
        border = Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          width: 0.8,
        );
        break;
    }

    final double verticalPadding = isSmall ? 3.0 : 5.0;
    final double horizontalPadding = isSmall ? 8.0 : 11.0;
    final double fontSize = isSmall ? 11.5 : 12.5;
    final double iconSize = isSmall ? 13.0 : 15.0;

    Widget pill = Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: pill,
      );
    }

    return pill;
  }
}
