// Level 5: Dart3

import 'models.dart';

sealed class ShelfState {
  const ShelfState();
}

final class Empty extends ShelfState {
  const Empty();
}

final class Ready extends ShelfState {
  final List<Book> books;

  const Ready(this.books);
}

final class Broken extends ShelfState {
  final String message;

  const Broken(this.message);
}

String describe(ShelfState state) => switch (state) {
      Empty() => 'Shelf is empty',
      Ready(books: final books) =>
        'Shelf holds ${books.length} book(s): ${books.map((b) => b.title).join(', ')}',
      Broken(message: final message) => 'Shelf is broken: $message',
    };

({int count, double avgPages}) statsOf(List<Book> books) => (
      count: books.length,
      avgPages: books.isEmpty
          ? 0
          : books.fold<double>(0, (sum, b) => sum + b.pages) / books.length,
    );