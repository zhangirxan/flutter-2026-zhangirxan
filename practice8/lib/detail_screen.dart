import 'package:flutter/material.dart';

import 'models/book.dart';

enum BookAction { toggleRead, delete }

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.book});

  final Book book;

  Future<void> _delete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete '${book.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    Navigator.of(context).pop(BookAction.delete);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(book.title, overflow: TextOverflow.ellipsis)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(title: Text(book.title), subtitle: const Text('Title')),
          ListTile(title: Text(book.author), subtitle: const Text('Author')),
          ListTile(title: Text('${book.pages}'), subtitle: const Text('Pages')),
          ListTile(
            title: Text(book.year?.toString() ?? 'Year unknown'),
            subtitle: const Text('Year'),
          ),
          ListTile(
            title: Text(book.read ? 'Read' : 'Not read yet'),
            subtitle: const Text('Status'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(BookAction.toggleRead),
            child: Text(book.read ? 'Mark as unread' : 'Mark as read'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _delete(context),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
