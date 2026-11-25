import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practice13/features/settings/settings_model.dart';
import 'package:practice13/features/users/users_model.dart';
import 'package:practice13/features/users/users_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../fakes/fake_user_repository.dart';

// the screen also watches SettingsModel (city filter), so it gets one too
Widget _screen(UsersModel model) => MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (_) => SettingsModel(SharedPreferencesAsync(), dark: false),
    ),
    ChangeNotifierProvider.value(value: model),
  ],
  child: const MaterialApp(home: UsersScreen()),
);

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('shows the offline view and Retry', (tester) async {
    final model = UsersModel(
      FakeUserRepository(fail: true, delay: const Duration(seconds: 1)),
    );
    final first = model.load();
    await tester.pump(const Duration(seconds: 1));
    await first;
    await tester.pumpWidget(_screen(model));

    expect(find.text('No connection'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 1)); // let the fake finish
  });

  testWidgets('loaded list shows both users', (tester) async {
    final model = UsersModel(FakeUserRepository());
    await model.load();
    await tester.pumpWidget(_screen(model));

    expect(find.text('Leanne Graham'), findsOneWidget);
    expect(find.text('Ervin Howell'), findsOneWidget);
    expect(find.text('Saved data · no connection'), findsNothing);
  });
}
