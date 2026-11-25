import 'package:flutter/foundation.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'user_repository.dart';

class UsersModel extends ChangeNotifier {
  UsersModel(this._repo);

  final UserRepository _repo;

  List<User> items = const [];
  ApiException? error;
  bool loading = false;
  bool fromCache = false; // true = old data, no connection

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final r = await _repo.getAll();
      items = r.items;
      fromCache = r.fromCache;
    } on ApiException catch (e) {
      error = e;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // errors go up to the form, it shows the SnackBar
  Future<void> add(User draft) async {
    final user = await _repo.create(draft);
    items = [user, ...items];
    notifyListeners();
  }
}
