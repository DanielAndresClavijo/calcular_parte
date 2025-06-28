import 'package:carabineros/widgets/seccion_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:carabineros/bloc/reporte_bloc.dart';
import 'package:carabineros/bloc/reporte_event.dart';
import 'package:carabineros/models/seccion_data.dart';

class SeccionWidget extends StatefulWidget {
  final int index;
  final SeccionData data;
  final VoidCallback? onDelete;

  const SeccionWidget({
    super.key,
    required this.index,
    required this.data,
    this.onDelete,
  });

  @override
  State<SeccionWidget> createState() => _SeccionWidgetState();
}

class _SeccionWidgetState extends State<SeccionWidget> {
  late final TextEditingController _feController;
  late final TextEditingController _fdController;
  late final TextEditingController _nvController;
  late final TextEditingController _detController;
  final _scrollController = ScrollController();

  final _feFocusNode = FocusNode();
  final _fdFocusNode = FocusNode();
  final _detFocusNode = FocusNode();
  final _nvFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _feController = TextEditingController(text: widget.data.fe);
    _fdController = TextEditingController(text: widget.data.fd);
    _nvController = TextEditingController(text: widget.data.nv);
    _detController = TextEditingController(text: widget.data.det);

    _feFocusNode.addListener(_ensureVisible);
    _fdFocusNode.addListener(_ensureVisible);
    _detFocusNode.addListener(_ensureVisible);
    _nvFocusNode.addListener(_ensureVisible);
  }

  @override
  void didUpdateWidget(SeccionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data.fe != _feController.text) {
      _feController.text = widget.data.fe;
    }
    if (widget.data.fd != _fdController.text) {
      _fdController.text = widget.data.fd;
    }
    if (widget.data.nv != _nvController.text) {
      _nvController.text = widget.data.nv;
    }
    if (widget.data.det != _detController.text) {
      _detController.text = widget.data.det;
    }
  }

  @override
  void dispose() {
    _feController.dispose();
    _fdController.dispose();
    _nvController.dispose();
    _detController.dispose();
    _scrollController.dispose();
    _feFocusNode.removeListener(_ensureVisible);
    _fdFocusNode.removeListener(_ensureVisible);
    _detFocusNode.removeListener(_ensureVisible);
    _nvFocusNode.removeListener(_ensureVisible);
    _feFocusNode.dispose();
    _fdFocusNode.dispose();
    _detFocusNode.dispose();
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
      _detFocusNode,
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

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sección ${widget.index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (widget.onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: widget.onDelete,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
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
                      width: width,
                      child: SeccionTextFieldWidget(
                        label: "FE:",
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
                        label: "FD:",
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
                        label: "NV:",
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
            const SizedBox(height: 10),
            const Text('Detalles de novedades:'),
            TextField(
              controller: _detController,
              maxLines: 3,
              focusNode: _detFocusNode,
              onChanged: (value) => context.read<ReporteBloc>().add(
                UpdateSeccion(widget.index, det: value),
              ),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
