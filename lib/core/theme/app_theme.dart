import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:innerbalance/core/theme/app_palette.dart';

class AppTheme {
  static final lightThemeMode = ThemeData.light().copyWith(
    scaffoldBackgroundColor: AppPalette.background,
    primaryColor: AppPalette.primary,
    colorScheme: const ColorScheme.light(
      primary: AppPalette.primary,
      secondary: AppPalette.secondary,
      surface: AppPalette.surface,
      background: AppPalette.background,
      error: AppPalette.error,
    ),
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: AppPalette.text,
      displayColor: AppPalette.text,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.background,
      elevation: 0,
      iconTheme: IconThemeData(color: AppPalette.text),
      titleTextStyle: TextStyle(
        color: AppPalette.text,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppPalette.surface,
      contentPadding: const EdgeInsets.all(16),
      border: _border(),
      enabledBorder: _border(),
      focusedBorder: _border(AppPalette.primary),
      errorBorder: _border(AppPalette.error),
    ),
  );

  static OutlineInputBorder _border([Color color = Colors.grey]) => OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      );
}
