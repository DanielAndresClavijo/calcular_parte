import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color.fromARGB(255, 191, 8, 228);
  
  static final MaterialColor _primarySwatch = MaterialColor(primaryColor.toARGB32(), {
    50: primaryColor.withValues(alpha: 0.1),
    100: primaryColor.withValues(alpha: 0.2),
    200: primaryColor.withValues(alpha: 0.3),
    300: primaryColor.withValues(alpha: 0.4),
    400: primaryColor.withValues(alpha: 0.5),
    500: primaryColor.withValues(alpha: 0.6),
    600: primaryColor.withValues(alpha: 0.7),
    700: primaryColor.withValues(alpha: 0.8),
    800: primaryColor.withValues(alpha: 0.9),
    900: primaryColor.withValues(alpha: 1.0),
  });

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      primarySwatch: _primarySwatch,
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: const TextTheme(
        labelSmall: TextStyle(
          fontSize: 12,
          color: Colors.black,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      primarySwatch: _primarySwatch,
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: const TextTheme(
        labelSmall: TextStyle(
          fontSize: 12,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static ThemeData getTheme(bool isDarkMode) {
    return isDarkMode ? darkTheme : lightTheme;
  }
}
