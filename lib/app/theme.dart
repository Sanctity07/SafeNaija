import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary
  static const Color green = Color(0xFF00C853);
  static const Color greenDark = Color(0xFF009624);
  static const Color greenGlow = Color(0x1A00C853);

  // Severity
  static const Color danger = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFF9500);
  static const Color safe = Color(0xFF00C853);

  // Backgrounds
  static const Color bg = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF141414);
  static const Color surface2 = Color(0xFF1E1E1E);

  // Borders
  static const Color border = Color(0xFF2A2A2A);

  // Text
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textMuted = Color(0xFF888888);
  static const Color white = Color(0xFFFFFFFF);

  // Severity backgrounds
  static const Color dangerBg = Color(0x1AFF3B30);
  static const Color warningBg = Color(0x1AFF9500);
  static const Color safeBg = Color(0x1A00C853);
}

class AppTextStyles {
  // Display — Syne
  static TextStyle displayLarge = GoogleFonts.syne(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.white,
    height: 1.1,
  );

  static TextStyle displayMedium = GoogleFonts.syne(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.white,
    height: 1.2,
  );

  static TextStyle displaySmall = GoogleFonts.syne(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  // Headings
  static TextStyle headingLarge = GoogleFonts.syne(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  static TextStyle headingMedium = GoogleFonts.syne(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  static TextStyle headingSmall = GoogleFonts.syne(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  // Body — DM Sans
  static TextStyle bodyLarge = GoogleFonts.dmSans(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.dmSans(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.4,
  );

  // Labels
  static TextStyle labelLarge = GoogleFonts.syne(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: AppColors.white,
  );

  static TextStyle labelSmall = GoogleFonts.syne(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.0,
    color: AppColors.textMuted,
  );

  // Caption
  static TextStyle caption = GoogleFonts.dmSans(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      primaryColor: AppColors.green,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.green,
        secondary: AppColors.greenDark,
        surface: AppColors.surface,
        error: AppColors.danger,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headingMedium,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),

      // Bottom Nav Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.green,
        unselectedItemColor: AppColors.textMuted,
        selectedLabelStyle: AppTextStyles.caption,
        unselectedLabelStyle: AppTextStyles.caption,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: AppTextStyles.labelLarge,
          elevation: 0,
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          side: const BorderSide(color: AppColors.border),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface2,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textMuted,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.green, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 0,
      ),

      // Card
      cardTheme: CardThemeData(
        color: AppColors.surface2,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}