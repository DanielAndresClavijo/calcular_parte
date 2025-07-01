import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:calcular_parte/theme/app_colors.dart';

class EditNameSeccionWidget extends StatefulWidget {
  final String initialName;

  const EditNameSeccionWidget({
    super.key,
    required this.initialName,
  });

  @override
  State<EditNameSeccionWidget> createState() => _EditNameSeccionWidgetState();
}

class _EditNameSeccionWidgetState extends State<EditNameSeccionWidget> {
  late final TextEditingController _textController;
  bool _isNameValid = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialName.trim());
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Nombre'),
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      content: Form(
        autovalidateMode: AutovalidateMode.always,
        onChanged: () {
          final isValid = _validateName(_textController.text) == null;
          if (isValid != _isNameValid) setState(() => _isNameValid = isValid);
        },
        child: TextFormField(
          controller: _textController,
          decoration: const InputDecoration(hintText: 'Nombre de la sección'),
          autofocus: true,
          maxLines: 1,
          textInputAction: TextInputAction.done,
          inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
          validator: _validateName,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _isNameValid ? () {
            final newName = _textController.text.trim();

            Navigator.of(context).pop(newName);
          } : null,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.white,
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.grey200,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre no puede estar vacío';
    }
    return null;
  }
}