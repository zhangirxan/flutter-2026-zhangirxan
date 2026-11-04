import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_badge.dart';
import 'models/book.dart';
import 'models/cart.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  // Ephemeral: only this screen cares about the search text.
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');
    final query = _search.text.trim().toLowerCase();
    final visible = books.where((b) => b.title.toLowerCase().contains(query));

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _search,
          onChanged: (_) => setState(() {}),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          decoration: const InputDecoration(
            hintText: 'Search books',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: const [CartBadge()],
      ),
      body: ListView(children: [for (final b in visible) _BookRow(book: b)]),
    );
  }
}

/// One row subscribes on its own, only to "is this book in the cart".
class _BookRow extends StatelessWidget {
  const _BookRow({required this.book});

  final Book book;

  void _add(BuildContext context) {
    final ok = context.read<Cart>().add(book);
    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Added')));
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('row ${book.title}');
    final added = context.select<Cart, bool>((c) => c.items.contains(book));
    return ListTile(
      title: Text(book.title),
      subtitle: Text('${book.author} · ${book.price} ₸'),
      trailing: added
          ? const Text('Added')
          : OutlinedButton(
              onPressed: () => _add(context),
              child: const Text('Add'),
            ),
    );
  }
}
