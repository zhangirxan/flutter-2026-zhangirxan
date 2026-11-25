import 'package:flutter/material.dart';

// shows which city the list is filtered by, x clears it
class CityFilterBar extends StatelessWidget {
  const CityFilterBar({super.key, required this.city, required this.onClear});

  final String city;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: InputChip(
          avatar: const Icon(Icons.location_city, size: 18),
          label: Text(city),
          onDeleted: onClear,
        ),
      ),
    );
  }
}
