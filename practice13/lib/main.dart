import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/api/api_client.dart';
import 'features/settings/settings_model.dart';
import 'core/storage/secure_store.dart';
import 'features/auth/auth_model.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_cache.dart';
import 'features/users/users_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // before any plugin

  // read from disk before the first frame, so there is no light flash
  final prefs = SharedPreferencesAsync();
  final dark = await prefs.getBool('darkMode') ?? false;
  final city = await prefs.getString('cityFilter'); // String?
  final avatar = await prefs.getString('avatarPath');

  const store = SecureStore();
  final token = await store.readToken();

  // the only place that wires everything together
  final api = ApiClient(store);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              SettingsModel(prefs, dark: dark, city: city, avatarPath: avatar),
        ),
        ChangeNotifierProvider(create: (_) => AuthModel(store, token: token)),
        ChangeNotifierProvider(
          create: (_) =>
              UsersModel(HttpUserRepository(api, const UsersCache()))..load(),
        ),
      ],
      child: const App(),
    ),
  );
}
