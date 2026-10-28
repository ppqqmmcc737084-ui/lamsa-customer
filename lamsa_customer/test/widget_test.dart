import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Lamsa customer test environment works', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('لمسة'))),
      ),
    );

    expect(find.text('لمسة'), findsOneWidget);
  });
}
