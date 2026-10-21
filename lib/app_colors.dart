import 'package:flutter/material.dart';

/// Centralized design tokens for Asrar-e-Tibb.
///
/// Based on `docs/2. DESIGN.md` and `docs/UI_MODERNIZATION_README.md`:
/// - Forest Green: `#064E3B` (Brand anchor, app bars, key headers)
/// - Evergreen: `#0B6B4B` (Primary actions, CTA buttons, active state)
/// - Fresh Green: `#23845B` (Success, positive selections, verified badges)
/// - Warm Ivory: `#F7F7F2` (Calm, glare-free page background)
/// - Pure White: `#FFFFFF` (Cards, sheets, elevated surfaces)
/// - Deep Ink: `#12231D` (High-contrast headings, main body text)
/// - Muted Text: `#64746C` (Secondary text, metadata, subtle subtitles)
/// - Soft Sage: `#E6F0EA` (Pills, badges, category chips, subtle blocks)
/// - Amber Accent: `#E6B84B` (Restrained highlights only)
class AppColors {
  AppColors._();

  // ------------------- Brand Colors -------------------
  /// Deep forest green for main brand identity, app bars, and headers.
  static const Color brandForest = Color(0xFF064E3B);

  /// Evergreen for primary interactive buttons and active states.
  static const Color brandGreen = Color(0xFF0B6B4B);

  /// Fresh herbal green for success states, verified badges, and active pills.
  static const Color brandFresh = Color(0xFF23845B);

  // ------------------- Surfaces & Backgrounds -------------------
  /// Warm ivory background for light mode pages (calm, glare-free).
  static const Color pageIvory = Color(0xFFF7F7F2);

  /// Pure white surface for cards, dialogs, and bottom sheets in light mode.
  static const Color surface = Color(0xFFFFFFFF);

  /// Subtle soft sage for chip backgrounds, pills, and input fills.
  static const Color softSage = Color(0xFFE6F0EA);

  /// Deep slate-forest background for dark mode scaffolds.
  static const Color scaffoldDark = Color(0xFF0F1713);

  /// Dark forest surface for cards and sheets in dark mode.
  static const Color surfaceDark = Color(0xFF16231C);

  /// Dark soft-sage container for chips in dark mode.
  static const Color softSageDark = Color(0xFF1E3127);

  // ------------------- Typography -------------------
  /// High-contrast deep ink for main headings and titles.
  static const Color ink = Color(0xFF12231D);

  /// Slightly lighter ink for body copy in light mode.
  static const Color inkSecondary = Color(0xFF2D4439);

  /// Muted sage-grey for metadata, secondary text, and hints.
  static const Color mutedText = Color(0xFF64746C);

  /// Muted text for dark mode.
  static const Color mutedTextDark = Color(0xFF94A59C);

  /// Pure white text for dark surfaces.
  static const Color textWhite = Color(0xFFFFFFFF);

  // ------------------- Borders & Dividers -------------------
  /// Subtle border for cards and containers in light mode.
  static const Color borderSubtle = Color(0xFFE1E8E3);

  /// Border for dark mode cards and inputs.
  static const Color borderDark = Color(0xFF24362C);

  // ------------------- Functional & Feedback -------------------
  /// Amber accent for small highlights, promotions, or pending state.
  static const Color accentAmber = Color(0xFFE6B84B);

  /// Soft amber background for warning/notice cards.
  static const Color accentAmberSoft = Color(0xFFFEF3C7);

  /// Clinical danger / error color.
  static const Color danger = Color(0xFFB42318);

  /// Soft danger background for error chips.
  static const Color dangerSoft = Color(0xFFFEE2E2);

  /// Warning text and icon color.
  static const Color warning = Color(0xFF8A5A00);

  /// Soft warning background.
  static const Color warningSoft = Color(0xFFFEF3C7);

  /// Success green.
  static const Color success = Color(0xFF166534);

  /// Soft success background.
  static const Color successSoft = Color(0xFFDCFCE7);

  // ------------------- Dynamic Resolvers -------------------
  /// Returns the appropriate scaffold background for the current brightness.
  static Color scaffoldBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? scaffoldDark
        : pageIvory;
  }

  /// Returns the appropriate surface color for cards and dialogs.
  static Color surfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? surfaceDark
        : surface;
  }

  /// Returns the appropriate main text color for readability.
  static Color textColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textWhite
        : ink;
  }

  /// Returns the appropriate muted text color for secondary labels.
  static Color secondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? mutedTextDark
        : mutedText;
  }

  /// Returns the appropriate border color for cards and fields.
  static Color borderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? borderDark
        : borderSubtle;
  }

  /// Returns the appropriate chip/pill container background.
  static Color pillContainer(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? softSageDark
        : softSage;
  }
}

