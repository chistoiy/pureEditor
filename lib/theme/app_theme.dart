import 'package:flutter/material.dart';

class AppTheme {
  static const Color lightBackground = Color(0xFFF5F5F0);
  static const Color lightTextPrimary = Color(0xFF333333);
  static const Color lightTextSecondary = Color(0xFF666666);
  static const Color lightPrimary = Color(0xFF4A6FA5);
  static const Color lightDanger = Color(0xFFD32F2F);

  static const Color darkBackground = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFF999999);
  static const Color darkPrimary = Color(0xFF5A8AC6);
  static const Color darkDanger = Color(0xFFEF5350);

  static const Color dayBackground = lightBackground;
  static const Color dayTextPrimary = lightTextPrimary;
  static const Color dayTextSecondary = lightTextSecondary;
  static const Color dayPrimary = lightPrimary;
  static const Color dayDanger = lightDanger;

  static const Color nightBackground = darkBackground;
  static const Color nightTextPrimary = darkTextPrimary;
  static const Color nightTextSecondary = darkTextSecondary;
  static const Color nightPrimary = darkPrimary;
  static const Color nightDanger = darkDanger;

  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      primaryColor: lightPrimary,
      colorScheme: ColorScheme.light(
        primary: lightPrimary,
        surface: lightBackground,
        error: lightDanger,
        onSurface: lightTextPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          color: lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: lightTextPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: lightTextSecondary, fontSize: 14),
        bodySmall: TextStyle(color: lightTextSecondary, fontSize: 12),
      ),
      iconTheme: IconThemeData(color: lightTextSecondary),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lightPrimary,
        foregroundColor: Colors.white,
      ),
      dividerColor: lightTextSecondary.withOpacity(0.2),
      cardColor: Colors.white,
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return lightPrimary;
          }
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return lightPrimary.withOpacity(0.5);
          }
          return Colors.grey.withOpacity(0.3);
        }),
      ),
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: darkPrimary,
      colorScheme: ColorScheme.dark(
        primary: darkPrimary,
        surface: darkBackground,
        error: darkDanger,
        onSurface: darkTextPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          color: darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: darkTextPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: darkTextSecondary, fontSize: 14),
        bodySmall: TextStyle(color: darkTextSecondary, fontSize: 12),
      ),
      iconTheme: IconThemeData(color: darkTextSecondary),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkPrimary,
        foregroundColor: Colors.white,
      ),
      dividerColor: darkTextSecondary.withOpacity(0.2),
      cardColor: const Color(0xFF2A2A2A),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkPrimary;
          }
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkPrimary.withOpacity(0.5);
          }
          return Colors.grey.withOpacity(0.3);
        }),
      ),
    );
  }
}
