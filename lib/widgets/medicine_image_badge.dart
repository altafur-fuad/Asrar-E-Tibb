import 'package:flutter/material.dart';
import '../app_colors.dart';

/// A deterministic, elegant product badge for medicines.
///
/// Solves the dataset limitation where no product photos exist:
/// If a genuine image is present, it displays it cleanly;
/// otherwise, it renders a clinical, branded badge with dosage-form iconography
/// and brand monogram rather than showing mismatched photos or developer portraits.
class MedicineImageBadge extends StatelessWidget {
  final String? imagePath;
  final String? dosageForm;
  final String brandName;
  final double size;
  final double borderRadius;
  final bool showDosageLabel;

  const MedicineImageBadge({
    super.key,
    this.imagePath,
    this.dosageForm,
    required this.brandName,
    this.size = 54.0,
    this.borderRadius = 12.0,
    this.showDosageLabel = false,
  });

  IconData _iconForDosageForm(String? form) {
    if (form == null || form.isEmpty) {
      return Icons.medication_rounded;
    }
    final lower = form.toLowerCase();
    if (lower.contains('syrup') || lower.contains('suspension') || lower.contains('liquid') || lower.contains('oral solution')) {
      return Icons.water_drop_rounded;
    }
    if (lower.contains('injection') || lower.contains('vial') || lower.contains('infusion') || lower.contains('ampoule')) {
      return Icons.vaccines_rounded;
    }
    if (lower.contains('drop')) {
      return Icons.opacity_rounded;
    }
    if (lower.contains('cream') || lower.contains('ointment') || lower.contains('gel')) {
      return Icons.healing_rounded;
    }
    if (lower.contains('inhaler') || lower.contains('spray') || lower.contains('nebuliser')) {
      return Icons.air_rounded;
    }
    if (lower.contains('capsule')) {
      return Icons.medication_liquid_rounded;
    }
    return Icons.medication_rounded;
  }

  String _extractMonogram(String name) {
    final cleaned = name.trim();
    if (cleaned.isEmpty) return 'M';
    final parts = cleaned.split(RegExp(r'[\s\-]+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return cleaned.substring(0, cleaned.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Check if a real image is provided (excluding developer portrait placeholder)
    final hasRealImage = imagePath != null &&
        imagePath!.isNotEmpty &&
        !imagePath!.contains('pic.png');

    if (hasRealImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          width: size,
          height: size,
          color: isDark ? AppColors.surfaceDark : AppColors.softSage,
          child: imagePath!.startsWith('http')
              ? Image.network(
                  imagePath!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildFallbackBadge(context, isDark),
                )
              : Image.asset(
                  imagePath!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildFallbackBadge(context, isDark),
                ),
        ),
      );
    }

    return _buildFallbackBadge(context, isDark);
  }

  Widget _buildFallbackBadge(BuildContext context, bool isDark) {
    final bg = isDark ? AppColors.softSageDark : AppColors.softSage;
    final fg = isDark ? AppColors.brandFresh : AppColors.brandForest;
    final border = isDark ? AppColors.borderDark : AppColors.borderSubtle;
    final icon = _iconForDosageForm(dosageForm);
    final monogram = _extractMonogram(brandName);

    final iconSize = size * 0.44;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: border, width: 1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background subtle monogram for visual depth
          if (size >= 48)
            Positioned(
              right: 4,
              bottom: 2,
              child: Text(
                monogram,
                style: TextStyle(
                  fontSize: size * 0.36,
                  fontWeight: FontWeight.w900,
                  color: fg.withValues(alpha: 0.12),
                  letterSpacing: -1,
                ),
              ),
            ),

          // Central clinical icon
          Center(
            child: Icon(
              icon,
              size: iconSize,
              color: fg,
            ),
          ),

          // Optional dosage pill badge at bottom when expanded (size >= 70)
          if (showDosageLabel && dosageForm != null && dosageForm!.isNotEmpty)
            Positioned(
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  dosageForm!,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

