import 'package:flutter/material.dart';

/// AppTheme defines the ChatGPT-inspired dark-gray design language
/// for the Password Vault application using Material 3.
class AppTheme {
  AppTheme._();

  // Color Tokens
  static const Color background = Color(0xFF212121);
  static const Color surface = Color(0xFF2B2B2B);
  static const Color elevatedSurface = Color(0xFF303030);
  static const Color border = Color(0xFF3A3A3A);
  static const Color primaryText = Color(0xFFF5F5F5);
  static const Color secondaryText = Color(0xFFAFAFAF);
  static const Color accent = Color(
    0xFF10A37F,
  ); // Restrained ChatGPT teal-green accent
  static const Color accentLight = Color(0xFF19C37D);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerSurface = Color(0xFF3A2020);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        onPrimary: Colors.white,
        surface: surface,
        onSurface: primaryText,
        error: danger,
        onError: Colors.white,
        outline: border,
      ),
      fontFamily: null, // Uses default clean platform font (Roboto/Segoe UI/San Francisco)
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: primaryText,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: primaryText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: elevatedSurface,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: border, width: 1),
        ),
        titleTextStyle: const TextStyle(
          color: primaryText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        hintStyle: const TextStyle(color: Color(0xFF757575), fontSize: 14),
        labelStyle: const TextStyle(color: secondaryText, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: danger, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: danger, width: 1.5),
        ),
        errorStyle: const TextStyle(color: danger, fontSize: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondaryText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: secondaryText),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: elevatedSurface,
        contentTextStyle: const TextStyle(color: primaryText, fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: border, width: 1),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
