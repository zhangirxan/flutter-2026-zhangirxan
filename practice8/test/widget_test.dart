import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practice8/library_screen.dart';
import 'package:practice8/models/book.dart';

void main() {
  test('model helpers', () {
    expect(totalPages(seed), 1220);
    expect(unread(seed).length, 4);
    expect(
      Book.fromMap({'title': 'X', 'author': 'Y', 'pages': 10}).toString(),
      'X — Y, 10 pp.',
    );
    expect(
      seed[1].toString(),
      'Null Safety for Humans — B. Seitkali, 196 pp. (2022)',
    );
  });

  testWidgets('filter changes the count in the title', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LibraryScreen()));
    expect(find.text('Reading list (5)'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Unread'));
    await tester.pump();
    expect(find.text('Reading list (4)'), findsOneWidget);
  });
}
