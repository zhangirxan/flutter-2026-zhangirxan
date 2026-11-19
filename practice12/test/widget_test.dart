import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:practice12/core/api/api_client.dart';
import 'package:practice12/core/api/api_exception.dart';
import 'package:practice12/core/settings/settings_model.dart';
import 'package:practice12/core/storage/secure_store.dart';
import 'package:practice12/features/users/user.dart';
import 'package:practice12/features/users/user_repository.dart';
import 'package:practice12/features/users/users_cache.dart';
import 'package:practice12/features/users/users_model.dart';
import 'package:practice12/features/users/users_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

const _user = {
  'id': 1,
  'name': 'Leanne Graham',
  'username': 'Bret',
  'email': 'Sincere@april.biz',
  'address': {
    'street': 'Kulas Light',
    'suite': 'Apt. 556',
    'city': 'Gwenborough',
    'zipcode': '92998-3874',
    'geo': {'lat': '-37.3159', 'lng': '81.1496'},
  },
  'phone': '1-770-736-8031 x56442',
  'website': 'hildegard.org',
  'company': {'name': 'Romaguera-Crona', 'catchPhrase': 'neural-net'},
};

// plugins don't run in tests, so memory versions instead
class _MemStore extends SecureStore {
  _MemStore([this.token]);
  String? token;

  @override
  Future<void> saveToken(String t) async => token = t;
  @override
  Future<String?> readToken() async => token;
  @override
  Future<void> clear() async => token = null;
}

class _MemCache extends UsersCache {
  _MemCache([this.saved]);
  List<User>? saved;

  @override
  Future<void> save(List<User> users) async => saved = users;
  @override
  Future<List<User>?> load() async => saved;
}

UserRepository _repo(
  MockClientHandler handler, {
  SecureStore? store,
  UsersCache? cache,
}) => UserRepository(
  ApiClient(MockClient(handler), store ?? _MemStore()),
  cache ?? _MemCache(),
);

Widget _app(UserRepository repo) => MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (_) => SettingsModel(SharedPreferencesAsync(), dark: false),
    ),
    ChangeNotifierProvider(create: (_) => UsersModel(repo)..load()),
  ],
  child: const MaterialApp(home: UsersScreen()),
);

Future<http.Response> _offline(http.Request _) async =>
    throw const SocketException('no route');

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('fromJson / toJson round trip', () {
    final u = User.fromJson(_user);
    expect(u.address.geo.lat, -37.3159);
    expect(User.fromJson(u.toJson()), u);
  });

  test('the token goes into the Authorization header by itself', () async {
    String? auth;
    final repo = _repo((req) async {
      auth = req.headers['Authorization'];
      return http.Response(jsonEncode([_user]), 200);
    }, store: _MemStore('tok_42'));
    await repo.getAll();
    expect(auth, 'Bearer tok_42');
  });

  test('no token, no header', () async {
    var hasAuth = true;
    final repo = _repo((req) async {
      hasAuth = req.headers.containsKey('Authorization');
      return http.Response(jsonEncode([_user]), 200);
    });
    await repo.getAll();
    expect(hasAuth, isFalse);
  });

  test(
    'online result is saved, offline returns it, nothing saved rethrows',
    () async {
      final cache = _MemCache();
      final online = _repo(
        (_) async => http.Response(jsonEncode([_user]), 200),
        cache: cache,
      );
      expect((await online.getAll()).fromCache, isFalse);
      expect(cache.saved, hasLength(1));

      final offline = _repo(_offline, cache: cache);
      final r = await offline.getAll();
      expect(r.fromCache, isTrue);
      expect(r.items.single.name, 'Leanne Graham');

      final empty = _repo(_offline);
      expect(empty.getAll(), throwsA(isA<NoConnectionException>()));
    },
  );

  testWidgets('offline with a cache: list plus the banner', (tester) async {
    final cache = _MemCache([User.fromJson(_user)]);
    await tester.pumpWidget(_app(_repo(_offline, cache: cache)));
    await tester.pump();
    expect(find.text('Leanne Graham'), findsOneWidget);
    expect(find.text('Saved data · no connection'), findsOneWidget);
  });

  testWidgets('online: list, no banner', (tester) async {
    await tester.pumpWidget(
      _app(_repo((_) async => http.Response(jsonEncode([_user]), 200))),
    );
    await tester.pump();
    expect(find.text('Leanne Graham'), findsOneWidget);
    expect(find.text('Saved data · no connection'), findsNothing);
  });

  testWidgets('offline, nothing saved: honest Offline screen', (tester) async {
    await tester.pumpWidget(_app(_repo(_offline)));
    await tester.pump();
    expect(find.text('No connection'), findsOneWidget);
    expect(find.text('Leanne Graham'), findsNothing);
  });
}
