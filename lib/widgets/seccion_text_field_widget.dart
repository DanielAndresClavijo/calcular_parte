import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SeccionTextFieldWidget extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool readOnly;
  final Color? backgroundColor;
  final ValueChanged<String>? onChanged;
  final bool isSmallScreen;
  final FocusNode? focusNode;

  const SeccionTextFieldWidget({
    super.key,
    required this.label,
    required this.controller,
    this.readOnly = false,
    this.backgroundColor,
    this.onChanged,
    this.isSmallScreen = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!isSmallScreen)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(label),
          ),
        Flexible(
          child: TextField(
            focusNode: focusNode,
            controller: controller,
            readOnly: readOnly,
            keyboardType: readOnly
                ? TextInputType.none
                : TextInputType.number,
            inputFormatters: readOnly
                ? []
                : [FilteringTextInputFormatter.digitsOnly],
            onChanged: onChanged,
            decoration: InputDecoration(
              label: isSmallScreen ? Text(label) : null,
              border: isSmallScreen ? const UnderlineInputBorder() : const OutlineInputBorder(),
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
}
