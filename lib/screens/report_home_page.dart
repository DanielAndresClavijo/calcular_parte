import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:share_plus/share_plus.dart';

import 'package:calcular_parte/bloc/reporte_bloc.dart';
import 'package:calcular_parte/bloc/reporte_event.dart';
import 'package:calcular_parte/bloc/reporte_state.dart';
import 'package:calcular_parte/models/resume_data.dart';
import 'package:calcular_parte/models/seccion_data.dart';
import 'package:calcular_parte/screens/report_detail_page.dart';
import 'package:calcular_parte/screens/tipos_management_page.dart';
import 'package:calcular_parte/theme/app_colors.dart';
import 'package:calcular_parte/widgets/card_resumen_widget.dart';
import 'package:calcular_parte/widgets/seccion_item_widget.dart';
import 'package:calcular_parte/widgets/title_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportHomePage extends StatelessWidget {
  const ReportHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityProvider(
      child: BlocProvider(
        create: (_) => ReporteBloc(),
        child: const ReportHomeView(),
      ),
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
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          content: Text(
            '¿Estás seguro de que quieres eliminar ${_selectedSections.length} sección(es)?',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Eliminar'),
              onPressed: () {
                context.read<ReporteBloc>().add(
                  RemoveMultipleSecciones(_selectedSections.toList()),
                );
                setState(() {
                  _isSelectionMode = false;
                  _selectedSections.clear();
                });
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
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
                          child: const TitleWidget('Total'),
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
                                      CardResumenWidget(
                                        title: 'Novedades (NV)',
                                        details: resumen.nv,
                                      ),
                                    ],
                                  );
                                },
                              ),
                        ),
                      ),
                    // SliverToBoxAdapter(child: const SizedBox(height: 16)),
                    SliverAppBar(
                      title: const TitleWidget('Secciones'),
                      pinned: true,
                      backgroundColor: Colors.white,
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
                  color: Colors.white,
                  elevation: 12,
                                      child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          // Botón de compartir
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final resumen = context
                                    .read<ReporteBloc>()
                                    .getResumenText();
                                SharePlus.instance.share(
                                  ShareParams(
                                    title: 'Reporte de Parte Carabineros',
                                    subject: 'Reporte de Parte',
                                    text: resumen,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Center(child: Icon(Icons.share)),
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
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white,
                                      ),
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
        backgroundColor: Colors.grey.shade300,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: true,
      );
    }
    return SliverAppBar(
      title: Column(
        children: [
          const Text('Calcular Parte'),
          Text(
            '',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.normal,
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
      titleTextStyle: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.normal),
      backgroundColor: Colors.white,
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
          final prefs = SharedPreferences.getInstance();
          return FutureBuilder(
            future: prefs,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                final tiposSugeridos =
                  snapshot.data?.getStringList('novedad_tipos') ?? [];
                return BlocProvider.value(
                  value: reporteBloc,
                  child: ReportDetailPage(
                    index: index,
                    tiposSugeridos: tiposSugeridos,
                  ),
                );
              }
              return Scaffold(
                backgroundColor: AppColors.white,
                body: const Center(child: CircularProgressIndicator()),
              );
            },
          );
        },
      ),
    );
  }
}
