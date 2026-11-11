import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'countdown_screen.dart';
import 'students_future_screen.dart';
import 'students_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // one api for the whole app, so the call counter doesn't reset per screen
  final _api = FakeApi();

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Practice 10')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
              onPressed: () => _open(StudentsScreen(api: _api)),
              child: const Text('By hand'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => _open(StudentsFutureScreen(api: _api)),
              child: const Text('FutureBuilder'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => _open(const CountdownScreen()),
              child: const Text('Countdown'),
            ),
          ],
        ),
      ),
    );
  }
}