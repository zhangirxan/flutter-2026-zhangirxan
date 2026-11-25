import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class Offline extends StatelessWidget {
  const Offline({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) =>
      _Message(icon: Icons.wifi_off, text: 'No connection', onRetry: onRetry);
}

class ServerError extends StatelessWidget {
  const ServerError(this.status, {super.key, required this.onRetry});

  final int status;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => _Message(
    icon: Icons.cloud_off,
    text: 'Server error ($status), try again later',
    onRetry: onRetry,
  );
}

class NotFoundView extends StatelessWidget {
  const NotFoundView({super.key});

  @override
  Widget build(BuildContext context) =>
      const _Message(icon: Icons.search_off, text: 'Nothing found');
}

// bad JSON: retrying won't help, it's a bug on our side
class GenericError extends StatelessWidget {
  const GenericError({super.key});

  @override
  Widget build(BuildContext context) =>
      const _Message(icon: Icons.bug_report, text: 'Something went wrong');
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.onRetry});

  final IconData icon;
  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final retry = onRetry;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 12),
          Text(text, style: Theme.of(context).textTheme.titleMedium),
          if (retry != null) ...[
            const SizedBox(height: 16),
            FilledButton(onPressed: retry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}
