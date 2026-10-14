import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practice5/contact_card.dart';
import 'package:practice5/contacts.dart';
import 'package:practice5/main.dart';

void main() {
  testWidgets('shows the header and the first contacts', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('20 contacts'), findsOneWidget);
    expect(find.text(contacts.first.name), findsOneWidget);
    expect(find.byType(Divider), findsWidgets);
  });

  testWidgets('long name fits a phone-width card', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ContactCard(contact: contacts[4])),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('badge only when there are unread messages', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ContactCard(contact: contacts[0]),
              ContactCard(contact: contacts[1]),
            ],
          ),
        ),
      ),
    );

    expect(contacts[0].unread, 0);
    expect(find.byType(Positioned), findsOneWidget);
  });
}
