import 'package:calcular_parte/models/novedad_detalle.dart';
import 'package:calcular_parte/theme/app_colors.dart';
import 'package:calcular_parte/widgets/cantidad_selector_widget.dart';
import 'package:flutter/material.dart';

class DetalleNovedadWidget extends StatelessWidget {
  final NovedadDetalle detalle;
  final int maxCantidad;
  final VoidCallback onRemove;
  final ValueChanged<NovedadDetalle> onUpdate;
  final List<String> tiposDisponibles;
  final VoidCallback onAddTipo;

  const DetalleNovedadWidget({
    super.key,
    required this.detalle,
    required this.maxCantidad,
    required this.onRemove,
    required this.onUpdate,
    required this.tiposDisponibles,
    required this.onAddTipo,
  });

  @override
  Widget build(BuildContext context) {
    final detalleDefault = const NovedadDetalleDefault();
    final bool isTipoValido = tiposDisponibles.contains(detalle.tipo);
    final bool isSinDefinir = detalle.tipo == detalleDefault.tipo;
    final Set<String> dropdownItemsSet = Set.from(tiposDisponibles);
    dropdownItemsSet.add(detalle.tipo);
    final List<String> dropdownItems = dropdownItemsSet.toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 600;
        final widthType = isWideScreen
            ? (constraints.maxWidth * 0.6) - 16
            : constraints.maxWidth;
        final widthQuantity = isWideScreen
            ? (constraints.maxWidth * 0.4) - 16
            : constraints.maxWidth;
        return Material(
          color: AppColors.grey200,
          borderRadius: BorderRadius.circular(8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                SizedBox(
                  width: widthType,
                  child: DropdownButtonFormField<String>(
                    value: detalle.tipo,
                    items: isSinDefinir
                        ? [
                            DropdownMenuItem(
                              value: detalle.tipo,
                              child: Text(detalle.tipo),
                            ),
                          ]
                        : [
                            ...dropdownItems.map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            ),
                            const DropdownMenuItem(
                              value: 'add_new',
                              child: Text('➕ Agregar nuevo tipo...'),
                            ),
                          ],
                    onChanged: isSinDefinir
                        ? null
                        : (value) {
                            if (value != null) {
                              if (value == 'add_new') {
                                onAddTipo();
                              } else if (value != detalle.tipo) {
                                onUpdate(detalle.copyWith(tipo: value));
                              }
                            }
                          },
                    decoration: InputDecoration(
                      labelText: 'Tipo',
                      border: const OutlineInputBorder(),
                      errorText: isTipoValido || isSinDefinir
                          ? null
                          : 'Tipo no disponible. Selecciónelo de la lista.',
                    ),
                  ),
                ),
                SizedBox(
                  width: widthQuantity,
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: CantidadSelectorWidget(
                            cantidad: detalle.cantidad,
                            maxCantidad: maxCantidad,
                            onChanged: isSinDefinir
                                ? null
                                : (newCantidad) {
                                    onUpdate(
                                      detalle.copyWith(cantidad: newCantidad),
                                    );
                                  },
                          ),
                        ),
                      ),
                      if (!isSinDefinir)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: onRemove,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
