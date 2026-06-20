import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ── Dark Theme (Royal Purple & Blue) ───────────────────────────────────────
  static const darkBackground = Color(0xFF14043D);
  static const darkSurface    = Color(0xFF1E0B5B);
  static const darkCard       = Color(0xFF1E0B5B);
  static const darkBorder     = Color(0xFF2D187A);

  static const tealPrimary    = Color(0xFF0CBFE2); // primaryBlue
  static const tealDark       = Color(0xFF047CBD);
  static const tealLight      = Color(0xFF9CE5F1); // lightBlue
  static const tealGlow       = Color(0xFF9CE5F1);

  static const darkText       = Color(0xFFFFFFFF);
  static const darkSubtext    = Color(0xFFC8C6D7);
  static const darkMuted      = Color(0xFF7A789B);

  // ── Light Theme (Warm Blue — no pure white) ────────────────────────────────
  static const lightBackground = Color(0xFFF0F7FB);  // Soft blue tint
  static const lightSurface    = Color(0xFFF7FBFE);  // Very light blue-white
  static const lightCard       = Color(0xFFF7FBFE);
  static const lightBorder     = Color(0xFFD6E9F2);  // Light blue border

  static const lavenderPrimary = Color(0xFF047CBD); // primaryColor (blue)
  static const lavenderLight   = Color(0xFF0CBFE2); // secondaryColor
  static const lavenderAccent  = Color(0xFF9CE5F1); // accentColor

  static const lightText       = Color(0xFF1F2937);
  static const lightSubtext    = Color(0xFF6B7280);
  static const lightMuted      = Color(0xFF9CA3AF);

  // ── Semantic Colors ────────────────────────────────────────────────────────
  static const excellent  = Color(0xFF34C759); // Success
  static const healthy    = Color(0xFF0CBFE2); 
  static const watch      = Color(0xFFF59E0B);
  static const risk       = Color(0xFFFF3B30); // Error
  static const riskLight  = Color(0xFFFFE5E5);

  // ── Gradients ──────────────────────────────────────────────────────────────
  static const darkGradient = LinearGradient(
    colors: [darkBackground, darkSurface],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const lightGradient = LinearGradient(
    colors: [Color(0xFFF0F7FB), Color(0xFFD6E9F2)],
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
        elevation: 0,
        shadowColor: const Color(0x0A000000),
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
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
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
        elevation: 0,
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
