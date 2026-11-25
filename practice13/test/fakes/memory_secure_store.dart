import 'package:practice13/core/storage/secure_store.dart';

// the real one needs the Keystore, tests keep the token in a field
class MemorySecureStore extends SecureStore {
  MemorySecureStore([this.token]);

  String? token;

  @override
  Future<void> saveToken(String t) async => token = t;

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> clear() async => token = null;
}
