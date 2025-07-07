import 'package:calcular_parte/models/novedad_detalle.dart';
import 'package:calcular_parte/widgets/add_novedad_dialog.dart';
import 'package:calcular_parte/widgets/detalle_novedad_widget.dart';
import 'package:calcular_parte/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:calcular_parte/bloc/reporte_bloc.dart';
import 'package:calcular_parte/bloc/reporte_event.dart';
import 'package:calcular_parte/bloc/reporte_state.dart';
import 'package:calcular_parte/theme/app_colors.dart';
import 'package:calcular_parte/widgets/edit_seccion_form_widget.dart';

class ReportDetailPage extends StatefulWidget {
  final int index;
  final List<String> tiposSugeridos;
  const ReportDetailPage({super.key, required this.index, required this.tiposSugeridos,});

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {

  @override
  Widget build(BuildContext context) {
    final detalleDefault = const NovedadDetalleDefault();
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocBuilder<ReporteBloc, ReporteState>(
        builder: (context, state) {
          final seccionData = state.secciones[widget.index];
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                title: Text(
                  'Edición de sección',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                backgroundColor: AppColors.white,
                surfaceTintColor: AppColors.grey500,
                centerTitle: true,
                actionsPadding: const EdgeInsets.only(right: 16.0),
                actions: [ const SizedBox.shrink() ],
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                sliver: SliverToBoxAdapter(
                  child: EditSeccionFormWidget(
                    index: widget.index,
                    data: seccionData,
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _PersistentHeader(
                  child: Material(
                    color: AppColors.white,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 16, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const TitleWidget('Detalle de Novedades'),
                          IconButton(
                            onPressed: () {
                              _addDetalle(detalleDefault, context);
                            },
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (seccionData.det.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No hay detalles de novedades.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  sliver: SliverList.separated(
                    separatorBuilder: (_, _) => const SizedBox(height: 8.0),
                    itemCount: seccionData.det.length,
                    itemBuilder: (context, index) {
                      final detalle = seccionData.det.elementAt(index);
                      return DetalleNovedadWidget(
                        key: ValueKey(detalle.tipo),
                        detalle: detalle,
                        maxCantidad: seccionData.det
                            .where((d) => d.tipo != detalle.tipo)
                            .fold((int.tryParse(seccionData.nv) ?? 0), (
                              prev,
                              element,
                            ) {
                              return prev -
                                  (element.tipo == detalleDefault.tipo
                                      ? 0
                                      : element.cantidad);
                            }),
                        onRemove: () => _removeDetalle(context, index),
                        onUpdate: (newDetalle) {
                          context.read<ReporteBloc>().add(
                            UpdateNovedadDetalle(
                                widget.index, index, newDetalle),
                          );
                        },
                        tiposDisponibles: widget.tiposSugeridos,
                        onAddTipo: () {}, // No se usa por ahora
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _addDetalle(
    NovedadDetalle detalleDefault,
    BuildContext context,
  ) async {
    final reporteBloc = context.read<ReporteBloc>();
    
    // Obtener el estado actual del bloc para tener datos actualizados
    final currentState = reporteBloc.state;
    final currentSeccionData = currentState.secciones[widget.index];
    
    final sinDefinirDetalle = currentSeccionData.det.firstWhere(
      (d) => d.tipo == detalleDefault.tipo,
      orElse: () => detalleDefault,
    );
    final cantidadDisponible = sinDefinirDetalle.cantidad;

    final newNovedad = await showDialog<NovedadDetalle>(
      context: context,
      builder: (context) => AddNovedadDialog(
        tiposSugeridos: widget.tiposSugeridos,
        tiposExistentes: currentSeccionData.det.map((d) => d.tipo).toList(),
        cantidadDisponible: cantidadDisponible,
      ),
    );

    if (newNovedad != null) {
      // Si se agregó un nuevo detalle, actualizamos el estado del bloc.
      reporteBloc.add(AddNovedadDetalle(widget.index, newNovedad));
    }
  }

  void _removeDetalle(BuildContext context, int detIndex) {
    context.read<ReporteBloc>().add(
      RemoveNovedadDetalle(widget.index, detIndex),
    );
  }

}

class _PersistentHeader extends SliverPersistentHeaderDelegate {
  final Widget child;

  _PersistentHeader({required this.child});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => kToolbarHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(_PersistentHeader oldDelegate) => false;
}