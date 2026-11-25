import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:practice13/features/users/user.dart';

import '../../fakes/user1_json.dart';

Map<String, dynamic> _user1() => jsonDecode(user1Json) as Map<String, dynamic>;

void main() {
  group('User.fromJson', () {
    test('real user 1 parses', () {
      final user = User.fromJson(_user1());

      expect(user.name, 'Leanne Graham');
      expect(user.address.city, 'Gwenborough');
      expect(user.address.geo.lat, -37.3159);
    });

    test('id as a string throws, the cast is a claim', () {
      final json = _user1()..['id'] = '1';

      expect(() => User.fromJson(json), throwsA(isA<TypeError>()));
    });

    // the planted bug from NOTES.md: lat came as a number, not a string
    test('Geo.fromJson with lat as a number throws', () {
      final json = {'lat': -37.3159, 'lng': '81.1496'};

      expect(() => Geo.fromJson(json), throwsA(isA<TypeError>()));
    });

    test('toJson gives back an equal user', () {
      final user = User.fromJson(_user1());

      expect(User.fromJson(user.toJson()), user);
    });
  });
}
