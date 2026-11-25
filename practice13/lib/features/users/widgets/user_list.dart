import 'package:flutter/material.dart';

import '../user.dart';
import 'user_tile.dart';

class UserList extends StatelessWidget {
  const UserList(this.users, {super.key});

  final List<User> users;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      // so pull-to-refresh works even when the list is short
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) => UserTile(users[i]),
    );
  }
}
