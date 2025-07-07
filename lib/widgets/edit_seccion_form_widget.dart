import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:calcular_parte/bloc/reporte_bloc.dart';
import 'package:calcular_parte/bloc/reporte_event.dart';
import 'package:calcular_parte/models/novedad_detalle.dart';
import 'package:calcular_parte/models/seccion_data.dart';
import 'package:calcular_parte/widgets/seccion_text_field_widget.dart';

class EditSeccionFormWidget extends StatefulWidget {
  final int index;
  final SeccionData data;
  final VoidCallback? onDelete;

  const EditSeccionFormWidget({
    super.key,
    required this.index,
    required this.data,
    this.onDelete,
  });

  @override
  State<EditSeccionFormWidget> createState() => _EditSeccionFormWidgetState();
}

class _EditSeccionFormWidgetState extends State<EditSeccionFormWidget> {
  late final TextEditingController _nombreSeccionController;
  late final TextEditingController _feController;
  late final TextEditingController _fdController;
  late final TextEditingController _nvController;

  final _nombreSeccionFocusNode = FocusNode();
  final _feFocusNode = FocusNode();
  final _fdFocusNode = FocusNode();
  final _nvFocusNode = FocusNode();

  final detalleDefault = const NovedadDetalleDefault();

  @override
  void initState() {
    super.initState();
    _nombreSeccionController = TextEditingController(text: widget.data.name);
    _feController = TextEditingController(text: widget.data.fe);
    _fdController = TextEditingController(text: widget.data.fd);
    _nvController = TextEditingController(text: widget.data.nv);

    _nombreSeccionFocusNode.addListener(_ensureVisible);
    _feFocusNode.addListener(_ensureVisible);
    _fdFocusNode.addListener(_ensureVisible);
    _nvFocusNode.addListener(_ensureVisible);
  }

  @override
  void didUpdateWidget(EditSeccionFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data.name != _nombreSeccionController.text) {
      _nombreSeccionController.text = widget.data.name;
    }
    if (widget.data.fe != _feController.text) {
      _feController.text = widget.data.fe;
    }
    if (widget.data.fd != _fdController.text) {
      _fdController.text = widget.data.fd;
    }
    if (widget.data.nv != _nvController.text) {
      _nvController.text = widget.data.nv;
    }
  }

  @override
  void dispose() {
    _nombreSeccionController.dispose();
    _feController.dispose();
    _fdController.dispose();
    _nvController.dispose();
    _nombreSeccionFocusNode.removeListener(_ensureVisible);
    _feFocusNode.removeListener(_ensureVisible);
    _fdFocusNode.removeListener(_ensureVisible);
    _nvFocusNode.removeListener(_ensureVisible);
    _nombreSeccionFocusNode.dispose();
    _feFocusNode.dispose();
    _fdFocusNode.dispose();
    _nvFocusNode.dispose();
    super.dispose();
  }

  Future<void> _ensureVisible() async {
    // Espera a que el teclado aparezca para que el cálculo del scroll sea correcto.
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final focusedNode = [
      _feFocusNode,
      _fdFocusNode,
      _nvFocusNode,
    ].firstWhere((node) => node.hasFocus, orElse: () => FocusNode());

    if (focusedNode.context != null) {
      Scrollable.ensureVisible(
        focusedNode.context!,
        duration: const Duration(milliseconds: 200),
        alignment: 0.1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final nvBackgroundColor = widget.data.nv == "!"
        ? Colors.red.shade200
        : Colors.white;

    return Form(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final spacing = 8.0;
          final isSmallScreen = constraints.maxWidth < 600;
          final width = isSmallScreen
              ? constraints.maxWidth
              : (constraints.maxWidth / 3) - spacing;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              SizedBox(
                width: constraints.maxWidth,
                child: SeccionTextFieldWidget(
                  label: "Nombre de la sección:",
                  controller: _nombreSeccionController,
                  isSmallScreen: isSmallScreen,
                  focusNode: _nombreSeccionFocusNode,
                  onChanged: (value) => context.read<ReporteBloc>().add(
                    UpdateSeccionName(widget.index, value),
                  ),
                ),
              ),
              SizedBox(
                width: width,
                child: SeccionTextFieldWidget(
                  label: "Fuerza efectiva (FE):",
                  controller: _feController,
                  isSmallScreen: isSmallScreen,
                  focusNode: _feFocusNode,
                  onChanged: (value) => context.read<ReporteBloc>().add(
                    UpdateSeccion(widget.index, fe: value),
                  ),
                ),
              ),
              SizedBox(
                width: width,
                child: SeccionTextFieldWidget(
                  label: "Fuerza Disponible (FD):",
                  controller: _fdController,
                  isSmallScreen: isSmallScreen,
                  focusNode: _fdFocusNode,
                  onChanged: (value) => context.read<ReporteBloc>().add(
                    UpdateSeccion(widget.index, fd: value),
                  ),
                ),
              ),
              SizedBox(
                width: width,
                child: SeccionTextFieldWidget(
                  label: "Novedades (NV):",
                  controller: _nvController,
                  isSmallScreen: isSmallScreen,
                  focusNode: _nvFocusNode,
                  readOnly: true,
                  backgroundColor: nvBackgroundColor,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
