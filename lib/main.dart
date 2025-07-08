import 'package:calcular_parte/bloc/reporte_bloc.dart';
import 'package:calcular_parte/bloc/theme_cubit.dart';
import 'package:calcular_parte/screens/splash_page.dart';
import 'package:calcular_parte/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const nameApp = '';

void main() {
  runApp(const ReportApp());
}

class ReportApp extends StatelessWidget {
  const ReportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ReporteBloc()),
        BlocProvider(create: (_) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          ThemeMode themeMode = ThemeMode.light;
          
          if (themeState is ThemeLoaded) {
            themeMode = themeState.themeMode;
          }
          
          return MaterialApp(
            title: 'Calcular Parte${nameApp.isNotEmpty ? ' - $nameApp' : ''}',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const SplashPage(),
          );
        },
      ),
    );
  }
}
