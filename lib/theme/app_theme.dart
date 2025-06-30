import 'package:flutter/material.dart';
import 'package:carabineros/theme/app_colors.dart';

class AppTheme {
  static final MaterialColor _primarySwatch = MaterialColor(AppColors.primary.value, {
    50: AppColors.primary.withValues(alpha: 0.1),
    100: AppColors.primary.withValues(alpha: 0.2),
    200: AppColors.primary.withValues(alpha: 0.3),
    300: AppColors.primary.withValues(alpha: 0.4),
    400: AppColors.primary.withValues(alpha: 0.5),
    500: AppColors.primary.withValues(alpha: 0.6),
    600: AppColors.primary.withValues(alpha: 0.7),
    700: AppColors.primary.withValues(alpha: 0.8),
    800: AppColors.primary.withValues(alpha: 0.9),
    900: AppColors.primary.withValues(alpha: 1.0),
  });

  static ThemeData get theme {
    return ThemeData(
      primaryColor: AppColors.primary,
      primarySwatch: _primarySwatch,
      scaffoldBackgroundColor: AppColors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      textTheme: TextTheme(
        labelSmall: TextStyle(
          fontSize: 12,
          color: AppColors.black,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
        ),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
