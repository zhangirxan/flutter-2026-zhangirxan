import '../../core/api/api_exception.dart';
import 'user.dart';
import 'user_repository.dart';

// two users, no network: for tests and for a demo on a machine without Wi-Fi
class FakeUserRepository implements UserRepository {
  FakeUserRepository({this.fail = false, this.delay = Duration.zero});

  final bool fail; // true -> every call is "no connection"
  final Duration delay;

  static const _json = [
    {
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
    },
    {
      'id': 2,
      'name': 'Ervin Howell',
      'username': 'Antonette',
      'email': 'Shanna@melissa.tv',
      'address': {
        'street': 'Victor Plains',
        'suite': 'Suite 879',
        'city': 'Wisokyburgh',
        'zipcode': '90566-7771',
        'geo': {'lat': '-43.9509', 'lng': '-34.4618'},
      },
      'phone': '010-692-6593 x09125',
      'website': 'anastasia.net',
      'company': {'name': 'Deckow-Crist', 'catchPhrase': 'didactic'},
    },
  ];

  Future<void> _wait() async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (fail) throw const NoConnectionException();
  }

  @override
  Future<UsersResult> getAll() async {
    await _wait();
    return (items: [for (final j in _json) User.fromJson(j)], fromCache: false);
  }

  @override
  Future<User> getById(int id) async {
    await _wait();
    for (final j in _json) {
      if (j['id'] == id) return User.fromJson(j);
    }
    throw const NotFoundException();
  }

  @override
  Future<User> create(User draft) async {
    await _wait();
    return User.fromJson({...draft.toJson(), 'id': 3});
  }
}
