// Template: widget test for a presentational widget.
// - Only used when the user explicitly asks for tests.
// - Wrap the widget in MaterialApp so Theme/Directionality/MediaQuery exist.
// - Pass dependencies via constructor — no global mocks needed.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// import the widget under test:
// import 'package:your_app/path/to/example_card.dart';

void main() {
  group('ExampleCard', () {
    testWidgets('renders title and subtitle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExampleCard(
              title: 'Hello',
              subtitle: 'World',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('World'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExampleCard(
              title: 'Hello',
              subtitle: 'World',
              onTap: () => tapped++,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ExampleCard));
      expect(tapped, 1);
    });
  });
}
