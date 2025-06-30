import 'package:carabineros/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CardResumenWidget extends StatelessWidget {
  final String title;
  final String details;

  const CardResumenWidget({
    super.key,
    required this.title,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(8.0),
      color: AppColors.grey200,
      clipBehavior: Clip.antiAlias,
      child: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w400,
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              details.isEmpty ? '0' : details,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.normal,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}