import 'dart:io';

import 'package:calcular_parte/theme/app_theme.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens/report_home_page.dart';

void main() {
  runApp(DevicePreview(
    enabled: kIsWeb || Platform.isWindows,
    builder: (_) => const ReportApp(),
  ));
}

class ReportApp extends StatelessWidget {
  const ReportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calcular Parte',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const ReportHomePage(),
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
    );
  }
}
