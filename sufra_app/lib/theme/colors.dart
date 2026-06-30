import 'package:flutter/material.dart';
import 'app_theme.dart';

/// "سُفرة" (Sufra) — warm, earthy, family-table palette.
/// Sufra is the Arabic word for the spread/table where a family gathers to eat —
/// chosen deliberately over a literal "scanner" name to feel warm, not clinical.
class SufraColors {
  static const Color terracotta = Color(0xFFB5663F);
  static const Color terracottaLight = Color(0xFFE3A37E);
  static const Color sage = Color(0xFF7C9866);
  static const Color sageDark = Color(0xFF627A52);
  static const Color cream = Color(0xFFFAF2E6);
  static const Color background = Color(0xFFF7EFE3);
  static const Color textDark = Color(0xFF3E2E22);
  static const Color textMuted = Color(0xFF8A7563);

  // Result / score colors — intentionally theme-independent so a "danger"
  // flag always reads as danger, light or dark mode.
  static const Color safe = Color(0xFF7C9866); // sage green
  static const Color caution = Color(0xFFD9A23B); // warm amber
  static const Color danger = Color(0xFFC1543A); // muted brick red

  /// Muted/secondary text color that's correct for the current theme
  /// (light or dark) — use this instead of the static [textMuted] constant
  /// anywhere text needs to adapt.
  static Color muted(BuildContext context) {
    return Theme.of(context).extension<SufraMutedTextColor>()?.color ?? textMuted;
  }

  /// Primary body text color for the current theme.
  static Color text(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge?.color ?? textDark;
  }

  /// Card/surface background color for the current theme.
  static Color surface(BuildContext context) {
    return Theme.of(context).cardTheme.color ?? cream;
  }

  /// Page background color for the current theme.
  static Color pageBackground(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }
}

