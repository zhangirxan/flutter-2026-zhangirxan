import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:practice11/core/api/api_client.dart';
import 'package:practice11/core/api/api_exception.dart';
import 'package:practice11/features/users/user.dart';
import 'package:practice11/features/users/user_repository.dart';
import 'package:practice11/features/users/users_model.dart';
import 'package:practice11/features/users/users_screen.dart';
import 'package:provider/provider.dart';

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

UserRepository _repo(MockClientHandler handler) =>
    UserRepository(ApiClient(MockClient(handler)));

Widget _app(UserRepository repo) => ChangeNotifierProvider(
  create: (_) => UsersModel(repo)..load(),
  child: const MaterialApp(home: UsersScreen()),
);

void main() {
  test('fromJson / toJson round trip', () {
    final u = User.fromJson(_user);
    expect(u.address.geo.lat, -37.3159);
    expect(u.phoneDigits, '1770736803156442');
    expect(User.fromJson(u.toJson()), u);
  });

  test('404 -> NotFoundException, bad JSON -> BadResponseException', () async {
    final notFound = _repo((_) async => http.Response('{}', 404));
    expect(notFound.getById(999), throwsA(isA<NotFoundException>()));

    final broken = _repo(
      (_) async => http.Response(jsonEncode({..._user, 'id': '1'}), 200),
    );
    expect(broken.getById(1), throwsA(isA<BadResponseException>()));
  });

  testWidgets('list from the server', (tester) async {
    await tester.pumpWidget(
      _app(_repo((_) async => http.Response(jsonEncode([_user]), 200))),
    );
    await tester.pump();
    expect(find.text('Leanne Graham'), findsOneWidget);
    expect(find.text('Sincere@april.biz · Gwenborough'), findsOneWidget);
  });

  testWidgets('no network -> Offline with Retry', (tester) async {
    await tester.pumpWidget(
      _app(_repo((_) async => throw const SocketException('no route'))),
    );
    await tester.pump();
    expect(find.text('No connection'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
