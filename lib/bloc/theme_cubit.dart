import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:calcular_parte/utils/theme_service.dart';

// Eventos del Cubit
abstract class ThemeEvent {}

class LoadTheme extends ThemeEvent {}

class ToggleTheme extends ThemeEvent {}

// Estados del Cubit
abstract class ThemeState {}

class ThemeInitial extends ThemeState {}

class ThemeLoaded extends ThemeState {
  final ThemeMode themeMode;
  
  ThemeLoaded(this.themeMode);
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeInitial()) {
    loadTheme();
  }

  Future<void> loadTheme() async {
    final isDarkMode = await ThemeService.isDarkMode();
    emit(ThemeLoaded(isDarkMode ? ThemeMode.dark : ThemeMode.light));
  }

  Future<void> toggleTheme() async {
    final currentState = state;
    if (currentState is ThemeLoaded) {
      final newThemeMode = currentState.themeMode == ThemeMode.light 
          ? ThemeMode.dark 
          : ThemeMode.light;
      
      await ThemeService.setDarkMode(newThemeMode == ThemeMode.dark);
      emit(ThemeLoaded(newThemeMode));
    }
  }
} 