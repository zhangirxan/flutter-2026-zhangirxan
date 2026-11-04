import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practice9/main.dart';

void main() {
  testWidgets('one Add tap rebuilds the whole Books screen', (tester) async {
    final log = <String>[];
    final original = debugPrint;
    debugPrint = (String? m, {int? wrapWidth}) => log.add(m ?? '');

    await tester.pumpWidget(const Shell());
    log.clear();
    await tester.tap(find.text('Add').first);
    await tester.pump();
    final lines = [...log];

    debugPrint = original;
    expect(find.text('Added'), findsOneWidget);
    // ignore: avoid_print
    print('LINES ${lines.length}: ${lines.join(' | ')}');
  });
}
