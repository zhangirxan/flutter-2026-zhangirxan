//  Level 3: null safety; Level 4: collections 

import 'models.dart';

class Library {
  final List<LibraryItem> items = [];

  late final DateTime openedAt;

  String? _cachedReport;

  void add(LibraryItem item) => items.add(item);

  void open() => openedAt = DateTime.now();

  List<Book> get books => items.whereType<Book>().toList();

  // Level 3

  Book? findByTitle(String title) {
    for (final item in items) {
      if (item is Book && item.title == title) return item;
    }
    return null;
  }

  String countryOf(String title) =>
      findByTitle(title)?.author.country ?? 'unknown';

  String report() => _cachedReport ??= displayLines.join('\n');

  //  Level 4

  List<String> get allTitles => books.map((b) => b.title).toList();

  List<Book> get publishedAfter2010 =>
      books.where((b) => b.year > 2010).toList();

  double get averagePages => books.isEmpty
      ? 0
      : books.fold<double>(0, (sum, b) => sum + b.pages) / books.length;

  Map<String, int> get booksPerAuthor =>
      books.fold<Map<String, int>>({}, (acc, b) {
        acc[b.author.name] = (acc[b.author.name] ?? 0) + 1;
        return acc;
      });

  Set<String> get authorNames => books.map((b) => b.author.name).toSet();

  Set<Genre> get genres => books.map((b) => b.genre).toSet();

  List<String> get displayLines => [
        'CATALOGUE',
        for (final b in books) '${b.title} (${b.year})',
        ...authorNames,
        if (books.any((b) => b.pages == 0)) '(incomplete data)',
      ];
}