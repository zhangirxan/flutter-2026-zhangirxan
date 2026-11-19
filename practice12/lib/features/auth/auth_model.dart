import 'package:flutter/foundation.dart';

import '../../core/storage/secure_store.dart';

class WrongPasswordException implements Exception {
  const WrongPasswordException();
}

class AuthModel extends ChangeNotifier {
  // main() reads the token before runApp and passes it here
  AuthModel(this._store, {this._token});

  final SecureStore _store;
  String? _token;

  bool get signedIn => _token != null;

  // only for the debug "copy token" button, never printed
  String? get token => _token;

  // fake server: any password with 8+ characters is fine
  Future<void> login(String email, String password) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (password.length < 8) throw const WrongPasswordException();
    final token = 'tok_${email.hashCode}';
    await _store.saveToken(token);
    _token = token;
    notifyListeners();
  }

  Future<void> logout() async {
    await _store.clear();
    _token = null;
    notifyListeners();
  }
}
