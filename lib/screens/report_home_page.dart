import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'package:calcular_parte/bloc/reporte_bloc.dart';
import 'package:calcular_parte/bloc/reporte_event.dart';
import 'package:calcular_parte/bloc/reporte_state.dart';
import 'package:calcular_parte/main.dart';
import 'package:calcular_parte/models/novedad_detalle.dart';
import 'package:calcular_parte/models/resume_data.dart';
import 'package:calcular_parte/models/seccion_data.dart';
import 'package:calcular_parte/screens/report_detail_page.dart';
import 'package:calcular_parte/screens/settings_page.dart';
import 'package:calcular_parte/screens/tipos_management_page.dart';
import 'package:calcular_parte/widgets/alert_dialog_base.dart';
import 'package:calcular_parte/widgets/card_resumen_widget.dart';
import 'package:calcular_parte/widgets/estadisticas_modal.dart';
import 'package:calcular_parte/widgets/seccion_item_widget.dart';
import 'package:calcular_parte/widgets/title_widget.dart';

class ReportHomePage extends StatelessWidget {
  const ReportHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityProvider(
      child: const ReportHomeView(),
    );
  }
}

class ReportHomeView extends StatefulWidget {
  const ReportHomeView({super.key});

  @override
  State<ReportHomeView> createState() => _ReportHomeViewState();
}

class _ReportHomeViewState extends State<ReportHomeView> {
  bool _isSelectionMode = false;
  final Set<int> _selectedSections = {};
  final _scrollController = ScrollController();

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialogBase(
          title: 'Confirmar eliminación',
          content: Text(
            '¿Estás seguro de que quieres eliminar ${_selectedSections.length} sección(es)?',
          ),
          confirmText: 'Eliminar',
          onConfirm: () {
            context.read<ReporteBloc>().add(
              RemoveMultipleSecciones(_selectedSections.toList()),
            );
            setState(() {
              _isSelectionMode = false;
              _selectedSections.clear();
            });
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Widget _buildTiposTotalesChips(List<SeccionData> secciones) {
    // Calcular totales por tipo
    final Map<String, int> tiposTotales = {};
    
    for (final seccion in secciones) {
      for (final detalle in seccion.det) {
        // Incluir todos los tipos, incluso con cantidad 0
        tiposTotales[detalle.tipo] = (tiposTotales[detalle.tipo] ?? 0) + detalle.cantidad;
      }
    }

    // Si no hay tipos, no mostrar nada
    if (tiposTotales.isEmpty) {
      return const SizedBox.shrink();
    }

    // Ordenar: tipo por defecto primero, luego por cantidad (descendente) y luego por nombre
    final sortedTipos = tiposTotales.entries.toList()
      ..sort((a, b) {
        // El tipo por defecto siempre va primero
        if (a.key == NovedadDetalleDefault.tipoDefault) return -1;
        if (b.key == NovedadDetalleDefault.tipoDefault) return 1;
        
        // Para el resto, ordenar por cantidad (descendente) y luego por nombre
        if (b.value != a.value) {
          return b.value.compareTo(a.value);
        }
        return a.key.compareTo(b.key);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.category, size: 20, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
            const SizedBox(width: 8),
            Text(
              'Tipos por Sección',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                // fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
                const SizedBox(height: 12),
        SizedBox(
          height: 40, // Altura fija para los chips
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 16),
            itemCount: sortedTipos.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final entry = sortedTipos[index];
              
              // Determinar el color del chip basado en si es el tipo por defecto y la cantidad
              final isDefaultType = entry.key == NovedadDetalleDefault.tipoDefault;
              final hasQuantity = entry.value > 0;
              
              Color chipColor;
              Color borderColor;
              Color textColor;
              
              if (isDefaultType) {
                chipColor = hasQuantity 
                    ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05);
                borderColor = hasQuantity 
                    ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2);
                textColor = hasQuantity ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
              } else {
                chipColor = hasQuantity 
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                    : Theme.of(context).primaryColor.withValues(alpha: 0.05);
                borderColor = hasQuantity 
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.3)
                    : Theme.of(context).primaryColor.withValues(alpha: 0.2);
                textColor = hasQuantity ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
              }
              
              return Chip(
                label: Text(
                  '${entry.key} ${entry.value}',
                  style: TextStyle(
                    fontWeight: hasQuantity ? FontWeight.w500 : FontWeight.normal,
                    fontSize: 12,
                    color: textColor,
                  ),
                ),
                backgroundColor: chipColor,
                side: BorderSide(
                  color: borderColor,
                  width: 1,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              );
            },
          ),
        ),
      ],
    );
  }



  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = KeyboardVisibilityProvider.isKeyboardVisible(
      context,
    );
    final secciones = context.watch<ReporteBloc>().state.secciones;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: BlocListener<ReporteBloc, ReporteState>(
                listenWhen: (previous, current) =>
                    previous.secciones.length < current.secciones.length,
                listener: (context, state) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent + 300,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    _buildAppBar(secciones.length),
                    if (!_isSelectionMode)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        sliver: SliverToBoxAdapter(
                          child: const TitleWidget('Totales'),
                        ),
                      ),
                    if (!_isSelectionMode)
                      SliverToBoxAdapter(child: const SizedBox(height: 16)),
                    if (!_isSelectionMode)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        sliver: SliverToBoxAdapter(
                          child:
                              BlocSelector<
                                ReporteBloc,
                                ReporteState,
                                ResumeData
                              >(
                                selector: (state) => state.resumen,
                                builder: (context, resumen) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: CardResumenWidget(
                                                title: 'Fuerza efectiva (FE)',
                                                details: resumen.fe,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Flexible(
                                              child: CardResumenWidget(
                                                title: 'Fuerza disponible (FD)',
                                                details: resumen.fd,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      GestureDetector(
                                        onTap: () => _showEstadisticasModal(context),
                                        child: CardResumenWidget(
                                          title: 'Novedades (NV)',
                                          details: resumen.nv,
                                          isClickable: true,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      _buildTiposTotalesChips(context.read<ReporteBloc>().state.secciones),
                                    ],
                                  );
                                },
                              ),
                        ),
                      ),
                    SliverAppBar(
                      title: const TitleWidget('Secciones'),
                      pinned: true,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      surfaceTintColor: Colors.transparent,
                      automaticallyImplyLeading: false,
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      sliver: SliverToBoxAdapter(
                        child:
                            BlocSelector<
                              ReporteBloc,
                              ReporteState,
                              List<SeccionData>
                            >(
                              selector: (state) => state.secciones,
                              builder: (context, secciones) {
                                if (secciones.isEmpty) {
                                  return SizedBox(
                                    height: 200,
                                    child: const Center(
                                      child: Text(
                                        'No hay secciones agregadas',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  );
                                }
                                return ListView.separated(
                                  key: const Key('listViewSecciones'),
                                  cacheExtent: 80,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: secciones.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 16),
                                  itemBuilder: (context, index) =>
                                      _buildSeccionItemWidget(context, index),
                                );
                              },
                            ),
                      ),
                    ),
                    SliverToBoxAdapter(child: const SizedBox(height: 100)),
                  ],
                ),
              ),
            ),
            if (!isKeyboardVisible && !_isSelectionMode)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 75,
                child: Material(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 12,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        // Botón de ajustes
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final reporteBloc = context.read<ReporteBloc>();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider.value(
                                    value: reporteBloc,
                                    child: const SettingsPage(),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Center(child: Icon(Icons.settings)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Botón de gestión de tipos
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final reporteBloc = context.read<ReporteBloc>();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider.value(
                                    value: reporteBloc,
                                    child: const TiposManagementPage(),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Center(child: Icon(Icons.category)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Botón de agregar campo
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () =>
                                context.read<ReporteBloc>().add(AddSeccion()),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Agregar Campo',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(int totalItems) {
    if (_isSelectionMode) {
      return SliverAppBar(
        title: Text('${_selectedSections.length} seleccionada(s)'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              _isSelectionMode = false;
              _selectedSections.clear();
            });
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              _selectedSections.length == totalItems
                  ? Icons.deselect
                  : Icons.select_all,
            ),
            onPressed: () {
              setState(() {
                if (_selectedSections.length == totalItems) {
                  _selectedSections.clear();
                } else {
                  _selectedSections.addAll(List.generate(totalItems, (i) => i));
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _selectedSections.isEmpty
                ? null
                : _showDeleteConfirmation,
          ),
        ],
        pinned: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: true,
      );
    }
    return SliverAppBar(
      title: Column(
        children: [
          const Text('Calcular Parte'),
          if (nameApp.isNotEmpty)
            Text(
              nameApp,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
        ],
      ),
      titleTextStyle: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.normal),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      pinned: true,
      automaticallyImplyLeading: false,
      centerTitle: true,
    );
  }

  Widget _buildSeccionItemWidget(BuildContext context, int index) {
    final seccionData = context.read<ReporteBloc>().state.secciones[index];
    final isSelected = _selectedSections.contains(index);

    return Hero(
      tag: 'seccion_item_$index',
      child: SeccionItemWidget(
        key: Key('seccion_item_$index'),
        index: index,
        seccionData: seccionData,
        isSelected: isSelected,
        onTap: (index) {
          if (_isSelectionMode) {
            setState(() {
              if (_selectedSections.contains(index)) {
                _selectedSections.remove(index);
              } else {
                _selectedSections.add(index);
              }
            });
          } else {
            _openSectionPage(context, index);
          }
        },
        onLongPress: (index) {
          if (!_isSelectionMode) {
            setState(() {
              _isSelectionMode = true;
              _selectedSections.add(index);
            });
          }
        },
      ),
    );
  }

  void _openSectionPage(BuildContext context, int index) {
    final reporteBloc = context.read<ReporteBloc>();

    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: 'ReportDetailPage', arguments: index),
        builder: (context) {
          return BlocProvider.value(
            value: reporteBloc,
            child: ReportDetailPage(
              index: index,
            ),
          );
        },
      ),
    );
  }

  void _showEstadisticasModal(BuildContext context) {
    final secciones = context.read<ReporteBloc>().state.secciones;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EstadisticasModal(secciones: secciones),
    );
  }
}
