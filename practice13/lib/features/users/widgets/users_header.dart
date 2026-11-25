import 'package:flutter/material.dart';

import '../../profile/profile_screen.dart';
import '../../settings/settings_screen.dart';

// AppBar with Profile and Settings, a widget so it can be const
class UsersHeader extends StatelessWidget implements PreferredSizeWidget {
  const UsersHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _open(BuildContext context, Widget screen) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Users'),
      actions: [
        IconButton(
          tooltip: 'Profile',
          icon: const Icon(Icons.account_circle),
          onPressed: () => _open(context, const ProfileScreen()),
        ),
        IconButton(
          tooltip: 'Settings',
          icon: const Icon(Icons.settings),
          onPressed: () => _open(context, const SettingsScreen()),
        ),
      ],
    );
  }
}
