import 'package:flutter/material.dart';

class CantidadSelectorWidget extends StatelessWidget {
  final int cantidad;
  final int maxCantidad;
  final ValueChanged<int>? onChanged;

  const CantidadSelectorWidget({
    super.key,
    required this.cantidad,
    required this.maxCantidad,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: cantidad > 0 && onChanged != null
              ? () => onChanged!(cantidad - 1)
              : null,
        ),
        DropdownButton<int>(
          value: cantidad,
          onChanged: onChanged != null
              ? (newValue) {
                  if (newValue != null) {
                    onChanged?.call(newValue);
                  }
                }
              : null,
          items: List.generate(maxCantidad + 1, (index) {
            return DropdownMenuItem<int>(
              value: index,
              child: Text(index.toString()),
            );
          }),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: cantidad < maxCantidad && onChanged != null
              ? () => onChanged!(cantidad + 1)
              : null,
        ),
      ],
    );
  }
}
