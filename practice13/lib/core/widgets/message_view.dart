import 'package:flutter/material.dart';

// icon + text + optional Retry, the base for every error view
class MessageView extends StatelessWidget {
  const MessageView({
    super.key,
    required this.icon,
    required this.text,
    this.onRetry,
  });

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
