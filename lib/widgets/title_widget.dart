import 'package:flutter/material.dart';

class TitleWidget extends StatelessWidget {
  final String title;
  const TitleWidget(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.normal),
        textAlign: TextAlign.start,
      ),
    );
  }
}
