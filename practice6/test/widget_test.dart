import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practice6/main.dart';

Future<void> openAidaEdit(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.tap(find.text('Aida Akhmetova'));
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.edit));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('list has no back arrow, detail has one', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(BackButton), findsNothing);

    await tester.tap(find.text('Aida Akhmetova'));
    await tester.pumpAndSettle();
    expect(find.text('IT-2302'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets('Save hands the new name back', (tester) async {
    await openAidaEdit(tester);
    await tester.enterText(find.byType(TextField), 'Aida A.');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Aida A.'), findsOneWidget);
    expect(find.text('Discard changes?'), findsNothing);
  });

  testWidgets('clean form goes back without asking', (tester) async {
    await openAidaEdit(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Discard changes?'), findsNothing);
    expect(find.text('IT-2302'), findsOneWidget);
  });

  testWidgets('dirty form asks, Keep stays, Discard leaves', (tester) async {
    await openAidaEdit(tester);
    await tester.enterText(find.byType(TextField), 'x');
    await tester.pump();

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);

    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(find.text('Edit name'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.text('Aida Akhmetova'), findsOneWidget);
    expect(find.text('IT-2302'), findsOneWidget);
  });
}
