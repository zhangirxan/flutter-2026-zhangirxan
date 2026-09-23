import 'package:flutter_test/flutter_test.dart';
import 'package:practice3/data.dart';
import 'package:practice3/info_row.dart';
import 'package:practice3/main.dart';

void main() {
  testWidgets('shows my name and one InfoRow per fact', (tester) async {
    await tester.pumpWidget(const ProfileApp());

    expect(find.text(myName), findsOneWidget);
    expect(find.byType(InfoRow), findsNWidgets(facts.length));
  });
}
