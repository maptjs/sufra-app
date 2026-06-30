import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class SufraTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: SufraColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: SufraColors.terracotta,
        brightness: Brightness.light,
        primary: SufraColors.terracotta,
        secondary: SufraColors.sage,
        surface: SufraColors.cream,
      ),
    );

    final textTheme = GoogleFonts.cairoTextTheme(base.textTheme).apply(
      bodyColor: SufraColors.textDark,
      displayColor: SufraColors.textDark,
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: SufraColors.background,
        foregroundColor: SufraColors.textDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: SufraColors.textDark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SufraColors.terracotta,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: SufraColors.cream,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SufraColors.cream,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      extensions: const [SufraMutedTextColor(SufraColors.textMuted)],
    );
  }

  static ThemeData dark() {
    const bg = Color(0xFF221A14);
    const surface = Color(0xFF2E241C);
    const textLight = Color(0xFFF1E6D8);
    const textMutedDark = Color(0xFFB9A793);

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: SufraColors.terracotta,
        brightness: Brightness.dark,
        primary: SufraColors.terracottaLight,
        secondary: SufraColors.sage,
        surface: surface,
      ),
    );

    final textTheme = GoogleFonts.cairoTextTheme(base.textTheme).apply(
      bodyColor: textLight,
      displayColor: textLight,
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: textLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textLight,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SufraColors.terracottaLight,
          foregroundColor: const Color(0xFF221A14),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(cursorColor: SufraColors.terracottaLight),
      extensions: const [SufraMutedTextColor(textMutedDark)],
    );
  }
}

/// A small ThemeExtension so widgets can read "the muted text color for the
/// current theme" without hardcoding light-mode colors everywhere.
class SufraMutedTextColor extends ThemeExtension<SufraMutedTextColor> {
  final Color color;
  const SufraMutedTextColor(this.color);

  @override
  SufraMutedTextColor copyWith({Color? color}) => SufraMutedTextColor(color ?? this.color);

  @override
  SufraMutedTextColor lerp(ThemeExtension<SufraMutedTextColor>? other, double t) {
    if (other is! SufraMutedTextColor) return this;
    return SufraMutedTextColor(Color.lerp(color, other.color, t) ?? color);
  }
}
