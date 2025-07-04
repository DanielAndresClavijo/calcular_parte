import 'package:calcular_parte/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'screens/report_home_page.dart';

void main() {
  runApp(const ReportApp());
}

class ReportApp extends StatelessWidget {
  const ReportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calcular Parte',
      theme: AppTheme.theme,
      home: const ReportHomePage(),
    );
  }
}
