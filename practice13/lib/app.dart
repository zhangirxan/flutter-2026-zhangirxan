import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/auth/auth_model.dart';
import 'features/auth/login_screen.dart';
import 'features/settings/settings_model.dart';
import 'features/users/users_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<SettingsModel>().dark;
    final signedIn = context.watch<AuthModel>().signedIn;
    return MaterialApp(
      title: 'Users',
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
      ),
      home: signedIn ? const UsersScreen() : const LoginScreen(),
    );
  }
}
