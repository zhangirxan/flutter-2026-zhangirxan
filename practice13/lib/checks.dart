import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'core/api/api_exception.dart';
import 'features/users/user.dart';
import 'features/users/user_repository.dart';

// Levels 2 and 3, run before runApp:
// flutter run --dart-define=CHECKS=true

const _user1 = r'''
{
  "id": 1,
  "name": "Leanne Graham",
  "username": "Bret",
  "email": "Sincere@april.biz",
  "address": {
    "street": "Kulas Light",
    "suite": "Apt. 556",
    "city": "Gwenborough",
    "zipcode": "92998-3874",
    "geo": {
      "lat": "-37.3159",
      "lng": "81.1496"
    }
  },
  "phone": "1-770-736-8031 x56442",
  "website": "hildegard.org",
  "company": {
    "name": "Romaguera-Crona",
    "catchPhrase": "Multi-layered client-server neural-net",
    "bs": "harness real-time e-markets"
  }
}
''';

Future<void> runChecks(UserRepository repo) async {
  // level 2
  final user = User.fromJson(jsonDecode(_user1) as Map<String, dynamic>);
  debugPrint('$user, phone digits: ${user.phoneDigits}');
  final again = User.fromJson(user.toJson());
  debugPrint('round trip equal: ${again == user}');

  // level 3
  final all = (await repo.getAll()).items;
  debugPrint('${all.length} users: ${all.map((u) => u.name).join(', ')}');
  try {
    await repo.getById(999);
  } on NotFoundException {
    debugPrint('not found');
  }
  final created = await repo.create(user);
  debugPrint('created with id ${created.id}');
}
