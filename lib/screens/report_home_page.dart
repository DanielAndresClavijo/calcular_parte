import 'package:carabineros/models/resume_data.dart';
import 'package:carabineros/models/seccion_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:carabineros/bloc/reporte_bloc.dart';
import 'package:carabineros/bloc/reporte_event.dart';
import 'package:carabineros/bloc/reporte_state.dart';
import 'package:carabineros/widgets/seccion_widget.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

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

const double _minBottomSheetSize = 0.3;
class _ReportHomeViewState extends State<ReportHomeView> {
  final _pageController = PageController();

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text(
            '¿Estás seguro de que quieres eliminar esta sección?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () {
                context.read<ReporteBloc>().add(RemoveSeccion(index));
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
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isSmallScreen = width < 600;
    final isKeyboardVisible = KeyboardVisibilityProvider.isKeyboardVisible(
      context,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escuela de carabineros'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned.fill(
                bottom: !isKeyboardVisible
                    ? constraints.maxHeight * _minBottomSheetSize
                    : 0,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              final resumen = context
                                  .read<ReporteBloc>()
                                  .getResumenText();
                              Clipboard.setData(ClipboardData(text: resumen));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Texto copiado al portapapeles',
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Copiar'),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                context.read<ReporteBloc>().add(ClearAll()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Limpiar'),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                context.read<ReporteBloc>().add(AddSeccion()),
                            child: const Text('Agregar Sección'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: BlocBuilder<ReporteBloc, ReporteState>(
                        builder: (context, state) {
                          if (isSmallScreen) {
                            return PageView.builder(
                              key: const Key('pageViewSections'),
                              controller: _pageController,
                              itemCount: state.secciones.length,
                              itemBuilder: (context, index) =>
                                  _buildSectionWidget(
                                    context,
                                    index,
                                    state.secciones,
                                  ),
                            );
                          }

                          return ListView.builder(
                            key: const Key('listViewSections'),
                            itemCount: state.secciones.length,
                            itemBuilder: (context, index) =>
                                _buildSectionWidget(
                                  context,
                                  index,
                                  state.secciones,
                                ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              Positioned.fill(
                child: Visibility(
                  visible: !isKeyboardVisible,
                  maintainState: true,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainInteractivity: true,
                  child: DraggableScrollableSheet(
                    initialChildSize: _minBottomSheetSize,
                    minChildSize: _minBottomSheetSize,
                    builder: (context, scrollController) {
                      return Material(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.grey[200],
                        child: BlocSelector<ReporteBloc, ReporteState, ResumeData>(
                          selector: (state) => state.resumen,
                          builder: (context, resumen) {
                            final secciones = context
                                .read<ReporteBloc>()
                                .state
                                .secciones;
                            return CustomScrollView(
                              controller: scrollController,
                              slivers: [
                                SliverToBoxAdapter(
                                  child: Center(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).hintColor,
                                        borderRadius:
                                            const BorderRadius.all(
                                              Radius.circular(10),
                                            ),
                                      ),
                                      height: 4,
                                      width: 40,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                    ),
                                  ),
                                ),
                                SliverAppBar(
                                  title: const Text(
                                    '📝 Resumen del Reporte',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  backgroundColor: Colors.transparent,
                                  pinned: true,
                                ),
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16,),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          resumen.getCopyText(),
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        ...secciones.map(
                                          (seccion) => Text(
                                            seccion.getCopyText(
                                              secciones.indexOf(seccion),
                                            ),
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Visibility(
        visible: !isKeyboardVisible,
        maintainState: true,
        maintainSize: true,
        maintainAnimation: true,
        maintainInteractivity: true,
        child: BottomAppBar(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    if (_pageController.hasClients) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
                BlocBuilder<ReporteBloc, ReporteState>(
                  builder: (context, state) {
                    return Text(
                      'Seccion ${_pageController.hasClients ? (_pageController.page?.round() ?? 0) +1 : 1} de ${context.read<ReporteBloc>().state.secciones.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    );
                  }
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    if (_pageController.hasClients) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionWidget(
    BuildContext context,
    int index,
    List<SeccionData> secciones,
  ) {
    final onDelete = secciones.length > 1
        ? () => _showDeleteConfirmation(index)
        : null;
    return SeccionWidget(
      key: Key('section_$index'),
      index: index,
      data: secciones[index],
      onDelete: onDelete,
    );
  }
}
