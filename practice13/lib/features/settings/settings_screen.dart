import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_model.dart';
import '../users/users_model.dart';
import 'settings_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();
    final cities = {
      for (final u in context.watch<UsersModel>().items)
        if (u.address.city.isNotEmpty) u.address.city,
    }.toList()..sort();
    // the saved city may not be in the list (e.g. nothing loaded yet)
    final city = cities.contains(settings.city) ? settings.city : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            value: settings.dark,
            onChanged: settings.setDark,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String?>(
              initialValue: city,
              decoration: const InputDecoration(labelText: 'City'),
              items: [
                const DropdownMenuItem(value: null, child: Text('All cities')),
                for (final c in cities)
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: settings.setCity,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () {
              // back to the root first, then the app switches to the login screen
              Navigator.of(context).popUntil((r) => r.isFirst);
              context.read<AuthModel>().logout();
            },
          ),
        ],
      ),
    );
  }
}
