import 'package:calcular_parte/widgets/alert_dialog_base.dart';
import 'package:calcular_parte/widgets/card_resumen_widget.dart';
import 'package:calcular_parte/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:calcular_parte/theme/app_colors.dart';
import 'package:calcular_parte/bloc/reporte_bloc.dart';
import 'package:calcular_parte/bloc/reporte_event.dart';
import 'package:calcular_parte/bloc/reporte_state.dart';

class TiposManagementPage extends StatefulWidget {
  const TiposManagementPage({super.key});

  @override
  State<TiposManagementPage> createState() => _TiposManagementPageState();
}

class _TiposManagementPageState extends State<TiposManagementPage> {
  String _formatTipo(String tipo) {
    // Remover caracteres especiales y espacios extra
    final formatted = tipo
        .trim()
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remover caracteres especiales
        .replaceAll(
          RegExp(r'\s+'),
          ' ',
        ) // Reemplazar múltiples espacios con uno solo
        .toLowerCase()
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '',
        )
        .join(' ')
        .trim();
    return formatted;
  }

  void _showAddTipoDialog() {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final reporteBloc = context.read<ReporteBloc>();
    final tiposActuales = reporteBloc.state.tiposSugeridos;

    showDialog(
      context: context,
      builder: (context) => AlertDialogBase(
        title: 'Agregar Nuevo Tipo',
        content: Form(
          key: formKey,
          child: CustomTextFieldWidget(
            controller: controller,
            isSmallScreen: true,
            label: 'Nombre',
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor, ingrese un nombre.';
              }
              if (tiposActuales.any(
                (tipo) => tipo.toLowerCase() == value.toLowerCase(),
              )) {
                return 'Este tipo ya existe.';
              }
              return null;
            },
          ),
        ),
        confirmText: 'Agregar',
        onConfirm: () {
          if (formKey.currentState!.validate()) {
            final nuevoTipo = _formatTipo(controller.text);
            reporteBloc.add(AddTipoSugerido(nuevoTipo));
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  void _showEditTipoDialog(String tipoOriginal) {
    final controller = TextEditingController(text: tipoOriginal);
    final formKey = GlobalKey<FormState>();
    final reporteBloc = context.read<ReporteBloc>();
    final tiposActuales = reporteBloc.state.tiposSugeridos;

    showDialog(
      context: context,
      builder: (context) => AlertDialogBase(
        title: 'Editar Tipo',
        content: Form(
          key: formKey,
          child: CustomTextFieldWidget(
            controller: controller,
            isSmallScreen: true,
            label: 'Nombre',
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor, ingrese un nombre.';
              }
              if (value.toLowerCase().trim() ==
                  tipoOriginal.toLowerCase().trim()) {
                return 'Este tipo ya existe.';
              }
              if (tiposActuales.any(
                (tipo) =>
                    tipo.toLowerCase() == value.toLowerCase() &&
                    tipo.toLowerCase() != tipoOriginal.toLowerCase(),
              )) {
                return 'Este tipo ya existe.';
              }
              return null;
            },
          ),
        ),
        confirmText: 'Guardar',
        onConfirm: () {
          if (formKey.currentState!.validate()) {
            final nuevoTipo = _formatTipo(controller.text);
            Navigator.of(context).pop(); // Cerrar diálogo de edición
            _showEditOptionsDialog(tipoOriginal, nuevoTipo);
          }
        },
      ),
    );
  }

  void _showEditOptionsDialog(String tipoOriginal, String nuevoTipo) {
    // Obtener el bloc antes de mostrar el diálogo
    final reporteBloc = context.read<ReporteBloc>();

    showDialog(
      context: context,
      builder: (context) {
        final isSmallScreen = MediaQuery.sizeOf(context).width < 600;
        final width = isSmallScreen
            ? MediaQuery.of(context).size.width - 80
            : (MediaQuery.of(context).size.width / 2) - 80;
        return AlertDialogBase(
          title: 'Opciones de Edición',
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('¿Cómo deseas aplicar el cambio?'),
                const SizedBox(height: 16),
                Flexible(
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: width,
                        child: CardResumenWidget(
                          title: 'Antes',
                          details: tipoOriginal,
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: CardResumenWidget(
                          title: 'Después',
                          details: nuevoTipo,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.update),
                  title: const Text('Aplicar a todas las secciones'),
                  subtitle: const Text(
                    'Sobrescribir en todas las secciones existentes',
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _updateTipoInAllSections(
                      tipoOriginal,
                      nuevoTipo,
                      reporteBloc,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Aplicar desde ahora'),
                  subtitle: const Text('Solo para nuevas secciones'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _updateTipoOnly(tipoOriginal, nuevoTipo, reporteBloc);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateTipoInAllSections(
    String tipoOriginal,
    String nuevoTipo,
    ReporteBloc reporteBloc,
  ) {
    // Actualizar en el bloc
    reporteBloc.add(UpdateTipoInAllSections(tipoOriginal, nuevoTipo));
    // Actualizar en la lista de tipos sugeridos
    reporteBloc.add(UpdateTipoSugerido(tipoOriginal, nuevoTipo));

    ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(
          'Tipo "$tipoOriginal" actualizado a "$nuevoTipo" en todas las secciones',
        ),
        backgroundColor: Colors.green,
      ),
      snackBarAnimationStyle: AnimationStyle(
        duration: const Duration(milliseconds: 200),
        reverseDuration: const Duration(milliseconds: 200),
        reverseCurve: Curves.linear,
        curve: Curves.linear,
      ),
    );
  }

  void _updateTipoOnly(
    String tipoOriginal,
    String nuevoTipo,
    ReporteBloc reporteBloc,
  ) {
    // Solo actualizar en la lista de tipos sugeridos
    reporteBloc.add(UpdateTipoSugerido(tipoOriginal, nuevoTipo));

    ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text('Tipo "$tipoOriginal" actualizado a "$nuevoTipo"'),
        backgroundColor: Colors.blue,
      ),
      snackBarAnimationStyle: AnimationStyle(
        duration: const Duration(milliseconds: 200),
        reverseDuration: const Duration(milliseconds: 200),
        reverseCurve: Curves.linear,
        curve: Curves.linear,
      ),
    );
  }

  Future<void> _showDeleteConfirmation(String tipo) async {
    // Verificar si el tipo está siendo usado en el bloc actual
    final reporteBloc = context.read<ReporteBloc>();
    final state = reporteBloc.state;

    bool isUsed = false;
    for (final seccion in state.secciones) {
      for (final detalle in seccion.det) {
        if (detalle.tipo == tipo) {
          isUsed = true;
          break;
        }
      }
      if (isUsed) break;
    }

    if (isUsed) {
      ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          content: Text(
            'No se puede eliminar un tipo que está siendo utilizado en alguna sección.',
          ),
          backgroundColor: Colors.red,
        ),
        snackBarAnimationStyle: AnimationStyle(
          duration: const Duration(milliseconds: 200),
          reverseDuration: const Duration(milliseconds: 200),
          reverseCurve: Curves.linear,
          curve: Curves.linear,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialogBase(
        title: 'Confirmar eliminación',
        content: Text('¿Estás seguro de que quieres eliminar el tipo "$tipo"?'),
        confirmText: 'Eliminar',
        onConfirm: () {
          reporteBloc.add(RemoveTipoSugerido(tipo));
          ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            SnackBar(
              content: Text('Tipo "$tipo" eliminado'),
              backgroundColor: Colors.orange,
            ),
            snackBarAnimationStyle: AnimationStyle(
              duration: const Duration(milliseconds: 200),
              reverseDuration: const Duration(milliseconds: 200),
              reverseCurve: Curves.linear,
              curve: Curves.linear,
            ),
          );
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Gestión de Tipos'),
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.black,
      ),
      body: BlocBuilder<ReporteBloc, ReporteState>(
        builder: (context, state) {
          final tipos = state.tiposSugeridos;

          if (tipos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay tipos creados',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega tu primer tipo de novedad',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: tipos.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final tipo = tipos[index];
              return Card(
                margin: const EdgeInsets.all(0),
                child: ListTile(
                  leading: const Icon(Icons.category),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                  title: Text(
                    tipo,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditTipoDialog(tipo),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _showDeleteConfirmation(tipo),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTipoDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }
}
