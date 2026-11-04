import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practice9/main.dart';
import 'package:practice9/models/cart.dart';
import 'package:provider/provider.dart';

Widget app() =>
    ChangeNotifierProvider(create: (_) => Cart(), child: const Shell());

void main() {
  testWidgets('Add, badge and cart share one Cart', (tester) async {
    await tester.pumpWidget(app());
    await tester.tap(find.text('Add').first);
    await tester.pump();
    await tester.tap(find.text('Add').first);
    await tester.pump();

    expect(
      find.descendant(of: find.byType(ListTile), matching: find.text('Added')),
      findsNWidgets(2),
    );
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.byTooltip('Cart'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('One more').first);
    await tester.pump();
    expect(find.textContaining('×2'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove').first);
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('badge rebuilds: three + presses, then a remove', (tester) async {
    final log = <String>[];
    final original = debugPrint;
    debugPrint = (String? m, {int? wrapWidth}) => log.add(m ?? '');

    await tester.pumpWidget(app());
    await tester.tap(find.text('Add').first);
    await tester.pump();
    await tester.tap(find.byTooltip('Cart'));
    await tester.pumpAndSettle();

    log.clear();
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byTooltip('One more'));
      await tester.pump();
    }
    final onPlus = log.where((l) => l == 'badge build').length;
    final rowsOnPlus = log.where((l) => l.startsWith('row ')).length;
    final labelOnPlus = log.where((l) => l == 'total label build').length;

    log.clear();
    await tester.tap(find.byTooltip('Remove'));
    await tester.pump();
    final onRemove = log.where((l) => l == 'badge build').length;

    debugPrint = original;
    // ignore: avoid_print
    print(
      'MEASURE badge on 3x+: $onPlus, rows on 3x+: $rowsOnPlus, '
      'total label on 3x+: $labelOnPlus, badge on remove: $onRemove',
    );
  });
}
