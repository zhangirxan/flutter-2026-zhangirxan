import 'package:flutter/material.dart';

import '../user.dart';
import '../user_detail_screen.dart';

class UserTile extends StatelessWidget {
  const UserTile(this.user, {super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    final city = user.address.city;
    return ListTile(
      leading: CircleAvatar(child: Text('${user.id}')),
      title: Text(user.name),
      subtitle: Text(city.isEmpty ? user.email : '${user.email} · $city'),
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => UserDetailScreen(user))),
    );
  }
}
