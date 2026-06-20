import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ── Dark Theme ─────────────────────────────────────────────────────────────
  static const darkBackground = Color(0xFF0F172A);   // Slate 900
  static const darkSurface    = Color(0xFF1E293B);   // Slate 800
  static const darkCard       = Color(0xFF243044);   // Slate 750
  static const darkBorder     = Color(0xFF334155);   // Slate 700

  static const tealPrimary    = Color(0xFF14B8A6);   // Teal 500
  static const tealDark       = Color(0xFF0D9488);   // Teal 600
  static const tealLight      = Color(0xFF5EEAD4);   // Teal 300
  static const tealGlow       = Color(0xFF99F6E4);   // Teal 200

  static const darkText       = Color(0xFFF1F5F9);   // Slate 100
  static const darkSubtext    = Color(0xFF94A3B8);   // Slate 400
  static const darkMuted      = Color(0xFF64748B);   // Slate 500

  // ── Light Theme ────────────────────────────────────────────────────────────
  // Rich Lavender Theme
  static const lightBackground = Color(0xFFF0E6FF);  // bg-primary
  static const lightSurface    = Color(0xFFE8D9FF);  // bg-secondary
  static const lightCard       = Color(0xFFDDC7FF);  // bg-tertiary
  static const lightBorder     = Color(0xFFD4C5F9);  // border

  static const lavenderPrimary = Color(0xFF7C3AED);  // accent-primary
  static const lavenderLight   = Color(0xFF6366F1);  // accent-secondary
  static const lavenderAccent  = Color(0xFF8B5CF6);  // accent-hover

  static const lightText       = Color(0xFF1E1B29);  // text-primary
  static const lightSubtext    = Color(0xFF4A4560);  // text-secondary
  static const lightMuted      = Color(0xFF6B6580);  // text-tertiary

  // ── Semantic Colors ────────────────────────────────────────────────────────
  static const excellent  = Color(0xFF059669); // accent-green (Light) / 10B981 (Dark)
  static const healthy    = Color(0xFF0891B2); // accent-cyan
  static const watch      = Color(0xFFF59E0B); // Amber
  static const risk       = Color(0xFFDB2777); // accent-pink
  static const riskLight  = Color(0xFFFCE7F3);

  // ── Gradients ──────────────────────────────────────────────────────────────
  static const darkGradient = LinearGradient(
    colors: [darkBackground, darkSurface],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const lightGradient = LinearGradient(
    colors: [Color(0xFFF0E6FF), Color(0xFFE8D9FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const tealGradient = LinearGradient(
    colors: [tealPrimary, tealDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  // ───────────────────────────────────────────────────────────────────────────
  // DARK THEME
  // ───────────────────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final base = GoogleFonts.poppinsTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.tealPrimary,
        secondary: AppColors.tealLight,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkText,
        outline: AppColors.darkBorder,
      ),
      textTheme: base.apply(
        bodyColor: AppColors.darkText,
        displayColor: AppColors.darkText,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.darkText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: AppColors.darkText),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.tealPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.tealPrimary, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.darkSubtext),
        hintStyle: const TextStyle(color: AppColors.darkMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      dividerColor: AppColors.darkBorder,
      iconTheme: const IconThemeData(color: AppColors.darkSubtext),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.tealPrimary,
        unselectedItemColor: AppColors.darkMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.tealPrimary,
        thumbColor: AppColors.tealPrimary,
        inactiveTrackColor: AppColors.darkBorder,
        overlayColor: AppColors.tealPrimary.withOpacity(0.2),
        trackHeight: 6,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.darkCard,
        contentTextStyle: TextStyle(color: AppColors.darkText),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // LIGHT THEME — Warm, accessible, high-contrast for all ages
  // ───────────────────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final base = GoogleFonts.poppinsTextTheme(
      ThemeData(brightness: Brightness.light).textTheme,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lavenderPrimary,
        secondary: AppColors.lavenderLight,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightText,
        outline: AppColors.lightBorder,
      ),
      textTheme: base.apply(
        bodyColor: AppColors.lightText,
        displayColor: AppColors.lightText,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.lightText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: AppColors.lightText),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 2,
        shadowColor: Color(0x14000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lavenderPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 1,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lavenderPrimary, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.lightSubtext, fontSize: 15),
        hintStyle: const TextStyle(color: AppColors.lightMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      dividerColor: AppColors.lightBorder,
      iconTheme: const IconThemeData(color: AppColors.lightSubtext),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.lavenderPrimary,
        unselectedItemColor: AppColors.lightMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.lavenderPrimary,
        thumbColor: AppColors.lavenderPrimary,
        inactiveTrackColor: AppColors.lightBorder,
        overlayColor: AppColors.lavenderPrimary.withOpacity(0.15),
        trackHeight: 6,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.lightText,
        contentTextStyle: TextStyle(color: AppColors.lightBackground),
      ),
    );
  }
}
