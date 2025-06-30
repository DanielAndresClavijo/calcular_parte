import 'package:carabineros/models/seccion_data.dart';
import 'package:carabineros/theme/app_colors.dart';
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
    final colorText = isSelected ? AppColors.white : AppColors.black;
    return Material(
      borderRadius: BorderRadius.circular(8.0),
      color: isSelected ? AppColors.primary : AppColors.grey200,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'FE\n',
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
                      text: 'FD\n',
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
                      text: 'NV\n',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
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
                      text: seccionData.det,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.normal,
                        color: colorText,
                      ),
                    ),
                  ],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
