import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practice7/main.dart';

void main() {
  testWidgets('Sign up is disabled until the rules are agreed', (tester) async {
    await tester.pumpWidget(const MyApp());
    final button = find.widgetWithText(FilledButton, 'Sign up');
    expect(tester.widget<FilledButton>(button).onPressed, isNull);

    await tester.ensureVisible(find.text('I agree to the rules'));
    await tester.tap(find.text('I agree to the rules'));
    await tester.pump();
    expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
  });

  testWidgets('empty form shows every error at once', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.ensureVisible(find.text('I agree to the rules'));
    await tester.tap(find.text('I agree to the rules'));
    await tester.pump();
    await tester.ensureVisible(find.text('Sign up').last);
    await tester.tap(find.widgetWithText(FilledButton, 'Sign up'));
    await tester.pump();

    expect(find.text('At least 2 characters'), findsOneWidget);
    expect(find.text('Email looks wrong'), findsOneWidget);
    expect(find.text('Choose a group'), findsOneWidget);
    expect(find.text('Pick your date of birth'), findsOneWidget);
  });
}
