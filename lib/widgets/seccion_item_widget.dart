import 'package:calcular_parte/models/seccion_data.dart';
import 'package:flutter/material.dart';

class SeccionItemWidget extends StatelessWidget {
  final int index;
  final SeccionData seccionData;
  final void Function(int index)? onTap;
  final void Function(int index)? onLongPress;
  final bool isSelected;

  const SeccionItemWidget({
    super.key,
    required this.index,
    required this.seccionData,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorText = isSelected ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).colorScheme.onSurface;
    return Card(
      color: isSelected ? Theme.of(context).primaryColor : null,
      margin: const EdgeInsets.all(0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap != null ? () => onTap!(index) : null,
        onLongPress: onLongPress != null ? () => onLongPress!(index) : null,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                seccionData.name.isNotEmpty ? seccionData.name : 'Sección ${index + 1}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.normal,
                  color: colorText,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'FE: ',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: colorText,
                      ),
                      children: [
                        TextSpan(
                          text: seccionData.fe.isEmpty ? '0' : seccionData.fe,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.normal,
                            color: colorText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  RichText(
                    text: TextSpan(
                      text: 'FD: ',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: colorText,
                      ),
                      children: [
                        TextSpan(
                          text: seccionData.fd.isEmpty ? '0' : seccionData.fd,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.normal,
                            color: colorText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  RichText(
                    text: TextSpan(
                      text: 'NV: ',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.normal,
                        color: colorText,
                      ),
                      children: [
                        TextSpan(
                          text: seccionData.nv.isEmpty ? '0' : seccionData.nv,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.normal,
                            color: colorText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              RichText(
                text: TextSpan(
                  text: 'Detalles: ',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.normal,
                    color: colorText,
                  ),
                  children: [
                    TextSpan(
                      text: seccionData.det.isEmpty
                          ? 'No hay detalles'
                          : seccionData.det.map((d) => '${d.emoji ?? ''} ${d.tipo} (${d.cantidad})').join(', '),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.normal,
                        color: colorText,
                      ),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
