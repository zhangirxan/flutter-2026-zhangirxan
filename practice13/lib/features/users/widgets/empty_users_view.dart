import 'package:flutter/material.dart';

// a list view, not a Center, so pull-to-refresh still works on it
class EmptyUsersView extends StatelessWidget {
  const EmptyUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 160),
      children: [
        Icon(Icons.group_off, size: 56, color: Theme.of(context).hintColor),
        const SizedBox(height: 12),
        const Text('No users here', textAlign: TextAlign.center),
      ],
    );
  }
}
