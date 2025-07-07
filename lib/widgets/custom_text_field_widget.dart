import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final bool readOnly;
  final Color? backgroundColor;
  final ValueChanged<String>? onChanged;
  final bool isSmallScreen;
  final FocusNode? focusNode;
  final void Function(String)? onSubmitted;
  final TextAlign? textAlign;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool? enabled;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextFieldWidget({
    super.key,
    required this.controller,
    this.label,
    this.readOnly = false,
    this.backgroundColor,
    this.onChanged,
    this.isSmallScreen = false,
    this.focusNode,
    this.onSubmitted,
    this.textAlign,
    this.validator,
    this.keyboardType = TextInputType.number,
    this.enabled = true,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!isSmallScreen && label != null)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(label!),
          ),
        Flexible(
          child: TextFormField(
            enabled: enabled,
            focusNode: focusNode,
            controller: controller,
            readOnly: readOnly,
            onFieldSubmitted: onSubmitted,
            validator: validator,
            textAlign: textAlign ?? TextAlign.start,
            keyboardType: keyboardType,
            inputFormatters: readOnly || keyboardType != TextInputType.number
                ? inputFormatters
                : [
                    FilteringTextInputFormatter.digitsOnly,
                    FilteringTextInputFormatter.singleLineFormatter,
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final formatted = _formatCantidad(newValue.text);
                      final offset = newValue.text.length > formatted.length
                          ? formatted.length
                          : null;
                      return newValue.copyWith(
                        text: formatted,
                        selection: offset != null
                            ? TextSelection.collapsed(offset: offset)
                            : null,
                      );
                    }),
                    ...inputFormatters ?? [],
                  ],
            onChanged: onChanged,
            decoration: InputDecoration(
              label: isSmallScreen && label != null ? Text(label!) : null,
              border: isSmallScreen
                  ? const UnderlineInputBorder()
                  : const OutlineInputBorder(),
              filled: true,
              fillColor: backgroundColor ?? Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Formateador personalizado para evitar ceros al inicio
  String _formatCantidad(String value) {
    if (value.isEmpty) return '';

    // Remover ceros al inicio
    String formatted = value.replaceAll(RegExp(r'^0+'), '');

    // Si después de remover ceros queda vacío, mantener solo un cero
    if (formatted.isEmpty) formatted = '0';

    return formatted;
  }
}
