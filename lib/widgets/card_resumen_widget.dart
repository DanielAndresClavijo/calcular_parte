import 'package:flutter/material.dart';

class CardResumenWidget extends StatelessWidget {
  final String title;
  final String details;
  final bool isClickable;

  const CardResumenWidget({
    super.key,
    required this.title,
    required this.details,
    this.isClickable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isClickable ? 2 : 0,
      margin: const EdgeInsets.all(0),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isClickable ? BorderSide(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
          width: 1,
        ) : BorderSide.none,
      ),
      child: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                if (isClickable)
                  Icon(
                    Icons.analytics,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
              ],
            ),
            const SizedBox(height: 4.0),
            Text(
              details.isEmpty ? '0' : details,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}