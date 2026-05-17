// Template: stateful widget with proper controller lifecycle.
// - Controllers created in initState, disposed in dispose.
// - State change via ValueNotifier so only the leaf rebuilds.
// - Callbacks are named methods on State for stable identity.

import 'package:flutter/material.dart';

class CounterCard extends StatefulWidget {
  const CounterCard({super.key, this.initialValue = 0});

  final int initialValue;

  @override
  State<CounterCard> createState() => _CounterCardState();
}

class _CounterCardState extends State<CounterCard> {
  late final ValueNotifier<int> _count;

  @override
  void initState() {
    super.initState();
    _count = ValueNotifier<int>(widget.initialValue);
  }

  @override
  void dispose() {
    _count.dispose();
    super.dispose();
  }

  void _increment() => _count.value++;
  void _decrement() => _count.value--;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: _decrement,
            ),
            _CountLabel(count: _count),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _increment,
            ),
          ],
        ),
      ),
    );
  }
}

class _CountLabel extends StatelessWidget {
  const _CountLabel({required this.count});

  final ValueNotifier<int> count;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: count,
      builder: (_, value, __) => Text(
        '$value',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
