// Template: presentational widget.
// - Receives data via constructor (no fetching inside).
// - All instance fields are `final`, constructor is `const`.
// - `build()` is short and reads top-to-bottom like a table of contents.
// - Private sub-widgets are real classes, not `_buildX()` methods.

import 'package:flutter/material.dart';

class ExampleCard extends StatelessWidget {
  const ExampleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Title(text: title),
            const SizedBox(height: 4),
            _Subtitle(text: subtitle),
          ],
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
