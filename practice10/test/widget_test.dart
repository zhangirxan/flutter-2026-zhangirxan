import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practice10/main.dart';

// collect debugPrint lines while body runs
Future<List<String>> withLog(Future<void> Function(List<String>) body) async {
  final log = <String>[];
  final original = debugPrint;
  debugPrint = (String? m, {int? wrapWidth}) => log.add(m ?? '');
  try {
    await body(log);
  } finally {
    debugPrint = original;
  }
  return log;
}

void main() {
  testWidgets('by hand: spinner, then the list', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('By hand'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Loading students…'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Aida Nurlanova'), findsOneWidget);
    expect(find.text('—'), findsOneWidget); // Aruzhan has no gpa
  });

  testWidgets('FutureBuilder: flipping the Switch does not refetch', (
    tester,
  ) async {
    final log = await withLog((log) async {
      await tester.pumpWidget(const MyApp());
      await tester.tap(find.text('FutureBuilder'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(seconds: 2));
      for (var i = 0; i < 10; i++) {
        await tester.tap(find.byType(Switch));
        await tester.pump();
      }
    });
    expect(find.text('Aida Nurlanova'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(log.where((l) => l.startsWith('fetchStudents')).toList(), [
      'fetchStudents #1',
    ]);
  });

  testWidgets('countdown B stops ticking after Back', (tester) async {
    var ticksAfterBack = <String>[];
    await withLog((log) async {
      await tester.pumpWidget(const MyApp());
      await tester.tap(find.text('Countdown'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('B: listen'));
      await tester.pump();
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      expect(find.text('7'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      log.clear();
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      ticksAfterBack = log.where((l) => l.startsWith('tick')).toList();
    });
    expect(ticksAfterBack, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
