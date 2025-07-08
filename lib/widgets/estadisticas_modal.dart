import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:calcular_parte/models/novedad_detalle.dart';
import 'package:calcular_parte/models/seccion_data.dart';


class EstadisticasModal extends StatefulWidget {
  final List<SeccionData> secciones;

  const EstadisticasModal({
    super.key,
    required this.secciones,
  });

  @override
  State<EstadisticasModal> createState() => _EstadisticasModalState();
}

class _EstadisticasModalState extends State<EstadisticasModal> {
  int? _selectedIndex;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tiposTotales = _calcularTiposTotales();
    final totalNovedades = tiposTotales.values.fold<int>(0, (sum, cantidad) => sum + cantidad);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header fijo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.pie_chart, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Text(
                  'Estadísticas de Novedades',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          // Contenido scrollable
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Resumen total
                  Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total de Novedades',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                totalNovedades.toString(),
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.analytics,
                              color: Theme.of(context).primaryColor,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Gráfico de pie
                  tiposTotales.isNotEmpty
                      ? _buildPieChart(context, tiposTotales, totalNovedades)
                      : _buildEmptyState(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _calcularTiposTotales() {
    final Map<String, int> tiposTotales = {};
    
    for (final seccion in widget.secciones) {
      for (final detalle in seccion.det) {
        tiposTotales[detalle.tipo] = (tiposTotales[detalle.tipo] ?? 0) + detalle.cantidad;
      }
    }
    
    return tiposTotales;
  }

  Widget _buildPieChart(BuildContext context, Map<String, int> tiposTotales, int totalNovedades) {
    final sortedTipos = tiposTotales.entries.toList()
      ..sort((a, b) {
        // El tipo por defecto siempre va primero
        if (a.key == NovedadDetalleDefault.tipoDefault) return -1;
        if (b.key == NovedadDetalleDefault.tipoDefault) return 1;
        
        // Para el resto, ordenar por cantidad (descendente)
        return b.value.compareTo(a.value);
      });

    return Column(
      children: [
        Text(
          'Distribución por Tipo',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 24),
        // Gráfico de pie con altura fija
        SizedBox(
          height: 300,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                enabled: true,
                touchCallback: (FlTouchEvent event, PieTouchResponse? touchResponse) {
                  if (event is FlTapUpEvent && touchResponse?.touchedSection != null) {
                    final touchedIndex = touchResponse!.touchedSection!.touchedSectionIndex;
                    setState(() {
                      _selectedIndex = touchedIndex;
                    });
                    
                    // Scroll al elemento seleccionado en la leyenda
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    });
                  }
                },
              ),
              sections: _buildPieSections(sortedTipos, totalNovedades),
              centerSpaceRadius: 60,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Leyenda
        SizedBox(
          height: 200,
          child: ListView.builder(
            itemCount: sortedTipos.length,
            itemBuilder: (context, index) {
              final entry = sortedTipos[index];
              final isDefaultType = entry.key == NovedadDetalleDefault.tipoDefault;
              final percentage = totalNovedades > 0 
                  ? ((entry.value / totalNovedades) * 100).toStringAsFixed(1)
                  : '0.0';
              final isSelected = _selectedIndex == index;
              
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected ? Border.all(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                    width: 1,
                  ) : null,
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: _getColorForIndex(index, isDefaultType),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            fontWeight: isSelected 
                                ? FontWeight.bold 
                                : (isDefaultType ? FontWeight.w600 : FontWeight.w500),
                            color: isSelected 
                                ? Theme.of(context).primaryColor 
                                : (isDefaultType ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6) : Theme.of(context).colorScheme.onSurface),
                          ),
                        ),
                      ),
                      Text(
                        '${entry.value} ($percentage%)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieSections(List<MapEntry<String, int>> sortedTipos, int totalNovedades) {
    return sortedTipos.asMap().entries.map((entry) {
      final index = entry.key;
      final tipoEntry = entry.value;
      final isDefaultType = tipoEntry.key == NovedadDetalleDefault.tipoDefault;
      final isSelected = _selectedIndex == index;
      
      return PieChartSectionData(
        color: _getColorForIndex(index, isDefaultType),
        value: tipoEntry.value.toDouble(),
        title: tipoEntry.value > 0 ? tipoEntry.key : '',
        radius: isSelected ? 110 : 100, // Radio más grande para la sección seleccionada
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
      );
    }).toList();
  }

  Color _getColorForIndex(int index, bool isDefaultType) {
    if (isDefaultType) {
      return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    }
    
    // Colores para tipos personalizados
    final colors = [
      Theme.of(context).primaryColor,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    
    return colors[index % colors.length];
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay datos para mostrar',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega novedades a las secciones para ver estadísticas',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 