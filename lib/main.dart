import 'package:calcular_parte/bloc/reporte_bloc.dart';
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
    return BlocProvider(
      create: (_) => ReporteBloc(),
      child: MaterialApp(
        title: 'Calcular Parte${nameApp.isNotEmpty ? ' - $nameApp' : ''}',
        theme: AppTheme.theme,
        home: const SplashPage(),
      ),
    );
  }
}
