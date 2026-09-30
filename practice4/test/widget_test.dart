import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practice4/main.dart';

void main() {
  testWidgets('tap card counts and resets only on Reset', (tester) async {
    await tester.pumpWidget(const MyApp());

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Tap this card'));
    }
    await tester.pump();
    expect(find.text('3'), findsOneWidget);

    await tester.longPress(find.text('Tap this card'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('3'), findsOneWidget);

    await tester.longPress(find.text('Tap this card'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset').last);
    await tester.pumpAndSettle();
    expect(find.text('3'), findsNothing);
  });

  testWidgets('minus is disabled at zero', (tester) async {
    await tester.pumpWidget(const MyApp());

    final minus = find.widgetWithText(OutlinedButton, '−');
    expect(tester.widget<OutlinedButton>(minus).onPressed, isNull);

    await tester.tap(find.widgetWithText(FilledButton, '+'));
    await tester.pump();
    expect(tester.widget<OutlinedButton>(minus).onPressed, isNotNull);
  });
}
