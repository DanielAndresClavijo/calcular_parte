import 'package:calcular_parte/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'dart:async';

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
  Timer? _holdTimer;
  int _holdDuration = 0;
  bool _isHolding = false;
  int _accumulatedChange = 0;

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  void _startHoldTimer(bool isIncrement) {
    if (_isHolding) return;
    _isHolding = true;
    _holdDuration = 0;
    _accumulatedChange = 0;
    
    _holdTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      _holdDuration += 200;
      
      // Calcular la velocidad basada en el tiempo de presión
      int increment = 1;
      if (_holdDuration > 1000) increment = 5;  // Después de 1 segundo: +5
      if (_holdDuration > 2000) increment = 10; // Después de 2 segundos: +10
      if (_holdDuration > 3000) increment = 25; // Después de 3 segundos: +25
      if (_holdDuration > 5000) increment = 50; // Después de 5 segundos: +50
      
      if (isIncrement) {
        final newValue = widget.cantidad + _accumulatedChange + increment;
        if (newValue <= widget.maxCantidad) {
          _accumulatedChange += increment;
          setState(() {}); // Actualizar la UI para mostrar el cambio
        } else {
          _stopHoldTimer();
        }
      } else {
        final newValue = widget.cantidad + _accumulatedChange - increment;
        if (newValue >= 0) {
          _accumulatedChange -= increment;
          setState(() {}); // Actualizar la UI para mostrar el cambio
        } else {
          _stopHoldTimer();
        }
      }
    });
  }

  void _stopHoldTimer() {
    _holdTimer?.cancel();
    _holdTimer = null;
    _isHolding = false;
    
    // Aplicar el cambio acumulado solo al final
    if (_accumulatedChange != 0 && widget.onChanged != null) {
      final finalValue = widget.cantidad + _accumulatedChange;
      if (finalValue >= 0 && finalValue <= widget.maxCantidad) {
        widget.onChanged!(finalValue);
      }
    }
    
    _holdDuration = 0;
    _accumulatedChange = 0;
  }

  @override
  Widget build(BuildContext context) {
    final enabledMinusButton = widget.cantidad > 0 && widget.onChanged != null;
    final enabledAddButton = widget.cantidad < widget.maxCantidad && widget.onChanged != null;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTapDown: enabledMinusButton ? (_) => _startHoldTimer(false) : null,
          onTapUp: enabledMinusButton ? (_) => _stopHoldTimer() : null,
          onTapCancel: enabledMinusButton ? () => _stopHoldTimer() : null,
          child: IconButton(
            icon: const Icon(Icons.remove),
            onPressed: enabledMinusButton
                ? () => widget.onChanged!(widget.cantidad - 1)
                : null,
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: !enabledMinusButton && !enabledAddButton
                    ? AppColors.grey500!
                    : AppColors.black,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${widget.cantidad + _accumulatedChange}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: !enabledMinusButton && !enabledAddButton
                    ? AppColors.grey500!
                    : AppColors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabledAddButton ? (_) => _startHoldTimer(true) : null,
          onTapUp: enabledAddButton ? (_) => _stopHoldTimer() : null,
          onTapCancel: enabledAddButton ? () => _stopHoldTimer() : null,
          child: IconButton(
            icon: const Icon(Icons.add),
            onPressed: enabledAddButton
                ? () => widget.onChanged!(widget.cantidad + 1)
                : null,
          ),
        ),
      ],
    );
  }
}
