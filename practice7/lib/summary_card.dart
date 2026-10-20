import 'package:flutter/material.dart';

/// What was signed up. Asks about its own box, never about the screen.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.name,
    required this.email,
    required this.group,
    required this.birthDate,
  });

  final String name;
  final String email;
  final String group;
  final String birthDate;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      ListTile(title: Text(name), subtitle: const Text('Name')),
      ListTile(title: Text(email), subtitle: const Text('Email')),
      ListTile(title: Text(group), subtitle: const Text('Group')),
      ListTile(title: Text(birthDate), subtitle: const Text('Date of birth')),
    ];

    return Card(
      child: LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth >= 600
            ? GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: tiles,
              )
            : Column(children: tiles),
      ),
    );
  }
}
