import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CantidadSelectorWidget extends StatefulWidget {
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
  State<CantidadSelectorWidget> createState() => _CantidadSelectorWidgetState();
}

class _CantidadSelectorWidgetState extends State<CantidadSelectorWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.cantidad.toString());
  }

  @override
  void didUpdateWidget(CantidadSelectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cantidad != oldWidget.cantidad) {
      _controller.text = widget.cantidad.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: widget.cantidad > 0 && widget.onChanged != null
              ? () => widget.onChanged!(widget.cantidad - 1)
              : null,
        ),
        Expanded(
          child: TextField(
            controller: _controller,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            onChanged: widget.onChanged != null
                ? (value) {
                    final newValue = int.tryParse(value);
                    if (newValue != null && newValue >= 0 && newValue <= widget.maxCantidad) {
                      widget.onChanged!(newValue);
                    }
                  }
                : null,
            onSubmitted: widget.onChanged != null
                ? (value) {
                    final newValue = int.tryParse(value);
                    if (newValue != null && newValue >= 0 && newValue <= widget.maxCantidad) {
                      widget.onChanged!(newValue);
                    }
                  }
                : null,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: widget.cantidad < widget.maxCantidad && widget.onChanged != null
              ? () => widget.onChanged!(widget.cantidad + 1)
              : null,
        ),
      ],
    );
  }
}
