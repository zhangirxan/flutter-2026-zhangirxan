import 'package:practice13/features/users/user.dart';
import 'package:practice13/features/users/users_cache.dart';

// no disk in unit tests: the "file" is a field
class MemoryUsersCache extends UsersCache {
  MemoryUsersCache([this.saved]);

  List<User>? saved;

  @override
  Future<void> save(List<User> users) async => saved = users;

  @override
  Future<List<User>?> load() async => saved;
}
