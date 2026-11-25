import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:practice13/core/api/api_client.dart';
import 'package:practice13/core/api/api_exception.dart';
import 'package:practice13/features/users/user_repository.dart';

import '../../fakes/memory_secure_store.dart';
import '../../fakes/memory_users_cache.dart';
import '../../fakes/user1_json.dart';

// MockClient answers instead of the server, that's why ApiClient takes a client
HttpUserRepository _repo(
  MockClientHandler handler, {
  MemorySecureStore? store,
  MemoryUsersCache? cache,
}) => HttpUserRepository(
  ApiClient(store ?? MemorySecureStore(), client: MockClient(handler)),
  cache ?? MemoryUsersCache(),
);

http.Response _list() => http.Response('[$user1Json]', 200);

void main() {
  group('status -> exception', () {
    test('404 -> NotFoundException', () {
      final repo = _repo((_) async => http.Response('{"error":"gone"}', 404));

      expect(repo.getById(99), throwsA(isA<NotFoundException>()));
    });

    test('500 -> ServerException', () {
      final repo = _repo((_) async => http.Response('oops', 500));

      expect(repo.getById(1), throwsA(isA<ServerException>()));
    });

    test('SocketException -> NoConnectionException', () {
      final repo = _repo((_) async => throw const SocketException('down'));

      expect(repo.getById(1), throwsA(isA<NoConnectionException>()));
    });
  });

  group('broken contract', () {
    // same bug as in user_test, but here it must come out as my exception,
    // so the screen shows the generic error instead of crashing
    test('lat as a number -> BadResponseException', () {
      final broken = user1Json.replaceFirst('"-37.3159"', '-37.3159');
      final repo = _repo((_) async => http.Response('[$broken]', 200));

      expect(repo.getAll(), throwsA(isA<BadResponseException>()));
    });
  });

  group('token', () {
    test('goes into the Authorization header by itself', () async {
      String? auth;
      final repo = _repo((req) async {
        auth = req.headers['Authorization'];
        return _list();
      }, store: MemorySecureStore('tok_42'));

      await repo.getAll();

      expect(auth, 'Bearer tok_42');
    });
  });

  group('cache', () {
    test('online saves, offline returns the saved list', () async {
      final cache = MemoryUsersCache();
      await _repo((_) async => _list(), cache: cache).getAll();

      final r = await _repo(
        (_) async => throw const SocketException('down'),
        cache: cache,
      ).getAll();

      expect(r.fromCache, isTrue);
      expect(r.items.single.name, 'Leanne Graham');
    });

    test('offline with nothing saved rethrows', () {
      final repo = _repo((_) async => throw const SocketException('down'));

      expect(repo.getAll(), throwsA(isA<NoConnectionException>()));
    });
  });
}
