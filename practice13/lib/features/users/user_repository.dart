import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';
import 'users_cache.dart';

typedef UsersResult = ({List<User> items, bool fromCache});

class UserRepository {
  UserRepository(this._api, [this._cache = const UsersCache()]);

  final ApiClient _api;
  final UsersCache _cache;

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.https(_api.host, path, query);

  // online: save and return fresh. offline: whatever we saved last time
  Future<UsersResult> getAll() async {
    try {
      final fresh = await _fetch();
      await _cache.save(fresh);
      return (items: fresh, fromCache: false);
    } on NoConnectionException {
      final saved = await _cache.load();
      if (saved == null) rethrow;
      return (items: saved, fromCache: true);
    }
  }

  Future<List<User>> _fetch() async {
    final json = await _api.get(_uri('/users'));
    return _parse('users', () {
      final list = json as List<dynamic>;
      return [for (final u in list) User.fromJson(u as Map<String, dynamic>)];
    });
  }

  Future<User> getById(int id) async {
    final json = await _api.get(_uri('/users/$id'));
    return _parse(
      'users/$id',
      () => User.fromJson(json as Map<String, dynamic>),
    );
  }

  // the server sends back what we posted plus its own id
  Future<User> create(User draft) async {
    final json = await _api.post(_uri('/users'), draft.toJson());
    return _parse(
      'POST users',
      () => User.fromJson(json as Map<String, dynamic>),
    );
  }

  // a bad cast in fromJson becomes my exception, with the field in the message
  T _parse<T>(String what, T Function() read) {
    try {
      return read();
    } on TypeError catch (e) {
      throw BadResponseException('$what: $e');
    } on FormatException catch (e) {
      throw BadResponseException('$what: ${e.message}');
    }
  }
}
