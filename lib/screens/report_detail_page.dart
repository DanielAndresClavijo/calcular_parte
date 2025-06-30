import 'package:calcular_parte/widgets/seccion_widget.dart';
import 'package:calcular_parte/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:calcular_parte/bloc/reporte_bloc.dart';
import 'package:calcular_parte/bloc/reporte_state.dart';
import 'package:calcular_parte/theme/app_colors.dart';
import 'package:calcular_parte/widgets/seccion_item_widget.dart';

class ReportDetailPage extends StatefulWidget {
  final int index;
  const ReportDetailPage({super.key, required this.index});

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text('Sección ${widget.index + 1}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<ReporteBloc, ReporteState>(
            builder: (context, state) {
              final seccionData = state.secciones[widget.index];
          
              return Column(
                children: [
                  Hero(
                    tag: 'seccion_item_${widget.index}',
                    child: SeccionItemWidget(
                      key: Key('seccion_item_${widget.index}'),
                      index: widget.index,
                      seccionData: seccionData,
                    ),
                  ),
                  const SizedBox(height: 7.0),
                  Divider(color: AppColors.grey200, thickness: 2.0),
                  const SizedBox(height: 7.0),
                  const TitleWidget('Editar'),
                  const SizedBox(height: 16.0),
                  SeccionWidget(
                    index: widget.index,
                    data: seccionData,
                  ),
                ],
              );
            }
          ),
        ),
      ),
    );
  }
}