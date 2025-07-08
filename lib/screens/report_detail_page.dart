import 'package:calcular_parte/bloc/reporte_state.dart';
import 'package:calcular_parte/models/seccion_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import 'package:calcular_parte/bloc/reporte_bloc.dart';
import 'package:calcular_parte/screens/report_edit_page.dart';
import 'package:calcular_parte/widgets/title_widget.dart';

class ReportDetailPage extends StatefulWidget {
  final int index;
  const ReportDetailPage({
    super.key,
    required this.index,
  });

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  @override
  Widget build(BuildContext context) {
    final seccionData = context
        .select<ReporteBloc, ReporteState>((state) => state.state)
        .secciones[widget.index];
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: Text(
              'Edición de sección',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
            centerTitle: true,
            actionsPadding: const EdgeInsets.only(right: 16.0),
            actions: [const SizedBox.shrink()],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
            sliver: SliverToBoxAdapter(
              child: Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          seccionData.name.isNotEmpty
                              ? seccionData.name
                              : 'Sección ${widget.index + 1}',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      _buildSummaryItem(
                        'Fuerza Efectiva',
                        seccionData.fe,
                        Icons.people,
                      ),
                      _buildSummaryItem(
                        'Fuerza Disponible',
                        seccionData.fd,
                        Icons.people_outline,
                      ),
                      _buildSummaryItem(
                        'Novedades',
                        seccionData.nv,
                        Icons.warning,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _PersistentHeader(
              child: Material(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 16, 0),
                  child: const TitleWidget('Detalle de Novedades'),
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
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
              sliver: SliverList.separated(
                separatorBuilder: (_, _) => const SizedBox(height: 8.0),
                itemCount: seccionData.det.length,
                itemBuilder: (context, index) {
                  final detalle = seccionData.det.elementAt(index);
                  return Card(
                    elevation: 0,
                    child: ListTile(
                      leading: Icon(Icons.category),
                      title: Text(detalle.tipo),
                      trailing: Text(detalle.cantidad.toString()),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _shareSeccion(seccionData),
                icon: Align(
                  alignment: Alignment.centerLeft,
                  child: const Icon(Icons.share),
                ),
                label: const Text('Compartir'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _navigateToEditView(),
                icon: Align(
                  alignment: Alignment.centerRight,
                  child: const Icon(Icons.edit),
                ),
                label: const Text('Editar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _shareSeccion(SeccionData seccionData) {
    final resumen = seccionData.getCopyText(widget.index);
    SharePlus.instance.share(
      ShareParams(
        title: 'Reporte de Parte Carabineros',
        subject: 'Reporte de Parte',
        text: resumen,
      ),
    );
  }

  void _navigateToEditView() {
    final reporteBloc = context.read<ReporteBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: reporteBloc,
          child: ReportEditPage(
            index: widget.index,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? '0' : value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
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
