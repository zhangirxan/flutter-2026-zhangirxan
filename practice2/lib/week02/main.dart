import 'catalogue.dart';
import 'data.dart';
import 'models.dart';
import 'shelf_state.dart';

void main() {
  final library = Library();
  library.open(); 

  for (final json in rawBooks) {
    library.add(Book.fromJson(json));
  }
  library.add(const Magazine(title: 'Dart Weekly', year: 2024, issue: 42));

  print('Opened at: ${library.openedAt}');
  print('');

  // Level 4 queries.
  print('Titles: ${library.allTitles}');
  print('After 2010: ${library.publishedAfter2010.map((b) => b.title).toList()}');
  print('Average pages: ${library.averagePages.toStringAsFixed(1)}');
  print('Books per author: ${library.booksPerAuthor}');
  print('Authors: ${library.authorNames}');
  print('Genres: ${library.genres.map((g) => g.label).toList()}');
  print('');

  // Level 3: 
  print('Find "Refactoring": ${library.findByTitle('Refactoring')}');
  print('Find "Missing Book": ${library.findByTitle('Missing Book')}');
  print('Country of "Design Patterns": ${library.countryOf('Design Patterns')}');
  print('Country of "Missing Book": ${library.countryOf('Missing Book')}');
  print('');

  // Level 1: getters и copyWith
  final broken = Book.fromJson(rawBooks.last);
  print('Broken entry: $broken');
  print('  isLong: ${broken.isLong}, isOld: ${broken.isOld}');
  print('  description: ${broken.description ?? 'none'}');
  print('  fixed copy: ${broken.copyWith(pages: 128, genre: Genre.craft)}');
  print('');

  // Level 2: один вызов, разные реализации
  for (final item in library.items) {
    print(item.describe());
  }
  print(library.books.first.borrowLabel());   // mixin
  print(const Ghost(title: 'The Lost Manuscript', year: 1812).describe());
  print('');

  // Level 5
  final stats = statsOf(library.books);
  print('Stats record: $stats');
  print('  count = ${stats.count}, avgPages = ${stats.avgPages.toStringAsFixed(1)}');
  print('');

  final states = <ShelfState>[
    const Empty(),
    Ready(library.books),
    const Broken('water damage on shelf 3'),
  ];
  for (final state in states) {
    print(describe(state));
  }
  print('');

  print(library.report());   // кеш через ??=
}