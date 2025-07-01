import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:calcular_parte/bloc/reporte_bloc.dart';
import 'package:calcular_parte/bloc/reporte_event.dart';
import 'package:calcular_parte/bloc/reporte_state.dart';
import 'package:calcular_parte/theme/app_colors.dart';
import 'package:calcular_parte/widgets/edit_name_seccion_widget.dart';
import 'package:calcular_parte/widgets/seccion_item_widget.dart';
import 'package:calcular_parte/widgets/seccion_widget.dart';
import 'package:calcular_parte/widgets/title_widget.dart';

class ReportDetailPage extends StatelessWidget {
  final int index;
  const ReportDetailPage({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocBuilder<ReporteBloc, ReporteState>(
        builder: (context, state) {
          final seccionData = state.secciones[index];
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                title: Text(seccionData.name),
                centerTitle: true,
                actions: [
                  // Edit name
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final newName = await showDialog<String?>(
                        context: context,
                        builder: (context) => EditNameSeccionWidget(
                          initialName: seccionData.name,
                        ),
                      );
                      if (newName != null && newName.isNotEmpty) {
                        if (!context.mounted) return;
                        context.read<ReporteBloc>().add(
                          UpdateSeccionName(index, newName),
                        );
                      }
                    },
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Hero(
                        tag: 'seccion_item_$index',
                        child: SeccionItemWidget(
                          key: Key('seccion_item_$index'),
                          index: index,
                          seccionData: seccionData,
                        ),
                      ),
                      const SizedBox(height: 7.0),
                      Divider(color: AppColors.grey200, thickness: 2.0),
                      const SizedBox(height: 7.0),
                      const TitleWidget('Editar'),
                      const SizedBox(height: 16.0),
                      SeccionWidget(index: index, data: seccionData),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}