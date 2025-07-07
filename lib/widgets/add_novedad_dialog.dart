import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:calcular_parte/models/novedad_detalle.dart';
import 'package:calcular_parte/widgets/alert_dialog_base.dart';
import 'package:calcular_parte/widgets/custom_text_field_widget.dart';

class AddNovedadDialog extends StatefulWidget {
  final List<String> tiposSugeridos;
  final List<String> tiposExistentes;
  final int cantidadDisponible;

  const AddNovedadDialog({
    super.key,
    required this.tiposSugeridos,
    required this.tiposExistentes,
    required this.cantidadDisponible,
  });

  @override
  State<AddNovedadDialog> createState() => _AddNovedadDialogState();
}

class _AddNovedadDialogState extends State<AddNovedadDialog> {
  String? _tipoSeleccionado;
  final _cantidadController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _newTipoController = TextEditingController();

  bool _showNewTipoDropdown = false;
  bool _enabledGuardarButton = false;

  @override
  void initState() {
    super.initState();
    _loadTipos();
    _cantidadController.text = widget.cantidadDisponible.toString();
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _newTipoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialogBase(
      title: 'Agregar Detalle de Novedad',
      content: Form(
        key: _formKey,
        onChanged: () {
          final isValid = _isFormValid();
          if (_enabledGuardarButton != isValid) {
            _enabledGuardarButton = isValid;
            setState(() {});
          }
        },
        autovalidateMode: AutovalidateMode.always,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_showNewTipoDropdown)
                DropdownButtonFormField<String>(
                  value: _tipoSeleccionado,
                  hint: const Text('Seleccionar tipo existente'),
                  items: widget.tiposSugeridos
                      .where(
                        (tipo) => !widget.tiposExistentes.any(
                          (e) => e.toLowerCase() == tipo.toLowerCase(),
                        ),
                      )
                      .map(
                        (tipo) =>
                            DropdownMenuItem(value: tipo, child: Text(tipo)),
                      )
                      .toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, seleccione un tipo.';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _tipoSeleccionado = value;
                    if (value != null) {
                      _newTipoController.clear();
                    }
                    _enabledGuardarButton = _isFormValid();
                    setState(() {});
                  },
                ),
              if (_tipoSeleccionado == null)
                CustomTextFieldWidget(
                  controller: _newTipoController,
                  isSmallScreen: true,
                  label: !_showNewTipoDropdown
                      ? 'Crear nuevo tipo'
                      : 'O crear nuevo tipo',
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    final isValid = ![...widget.tiposSugeridos, ...widget.tiposExistentes].any(
                      (e) => e.toLowerCase() == value?.toLowerCase(),
                    );
                    if (value != null && value.isNotEmpty && !isValid) {
                      return 'Este tipo ya existe en la sección.';
                    }
                    return null;
                  },
                ),
              CustomTextFieldWidget(
                controller: _cantidadController,
                isSmallScreen: true,
                label: 'Cantidad (Disponible: ${widget.cantidadDisponible})',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese una cantidad.';
                  }
                  final cantidad = int.tryParse(value);
                  if (cantidad == null) {
                    return 'Ingrese un número válido.';
                  }
                  if (cantidad < 0) {
                    return 'La cantidad no puede ser negativa.';
                  }
                  if (cantidad > widget.cantidadDisponible) {
                    return 'La cantidad excede lo disponible.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      confirmText: 'Guardar',
      onConfirm: _enabledGuardarButton ? _onGuardar : null,      
    );
  }

  bool _isFormValid() {
    // Validar tipo
    final tipo = _tipoSeleccionado ?? _newTipoController.text;
    if (tipo.isEmpty) return false;
    if (widget.tiposExistentes.any(
      (e) => e.toLowerCase() == tipo.toLowerCase(),
    )) {
      return false;
    }

    // Validar cantidad
    final cantidadText = _cantidadController.text;
    if (cantidadText.isEmpty) return false;

    final cantidad = int.tryParse(cantidadText);
    if (cantidad == null ||
        cantidad < 0 ||
        cantidad > widget.cantidadDisponible) {
      return false;
    }

    return true;
  }

  Future<void> _loadTipos() async {
    _showNewTipoDropdown = widget.tiposSugeridos
        .where(
          (tipo) => !widget.tiposExistentes.any(
            (e) => e.toLowerCase() == tipo.toLowerCase(),
          ),
        )
        .isNotEmpty;
  }

  Future<void> _saveTipo(String tipo) async {
    if (!widget.tiposSugeridos.any(
      (e) => e.toLowerCase() == tipo.toLowerCase(),
    )) {
      final newTipos = {...widget.tiposSugeridos, tipo};
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('novedad_tipos', newTipos.toList());
    }
  }

  void _onGuardar() {
    if (_formKey.currentState!.validate()) {
      final tipo = _tipoSeleccionado ?? _newTipoController.text;
      final cantidad = int.tryParse(_cantidadController.text) ?? 0;

      if (tipo.isNotEmpty) {
        if (_tipoSeleccionado == null) {
          _saveTipo(tipo);
        }
        Navigator.of(
          context,
        ).pop(NovedadDetalle(tipo: tipo, cantidad: cantidad));
      }
    }
  }

}
