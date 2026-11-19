import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'user.dart';

// last good list from the server, in Documents (Temporary can be wiped by the OS)
class UsersCache {
  const UsersCache();

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}${Platform.pathSeparator}users.json');
  }

  Future<void> save(List<User> users) async {
    final file = await _file();
    await file.writeAsString(jsonEncode([for (final u in users) u.toJson()]));
  }

  // null = nothing saved yet
  Future<List<User>?> load() async {
    final file = await _file();
    if (!await file.exists()) return null;
    try {
      final list = jsonDecode(await file.readAsString()) as List<dynamic>;
      return [for (final u in list) User.fromJson(u as Map<String, dynamic>)];
    } on FormatException {
      return null; // broken file, act like there is no cache
    } on TypeError {
      return null;
    }
  }
}
