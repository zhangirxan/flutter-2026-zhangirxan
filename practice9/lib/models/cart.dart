import 'package:flutter/foundation.dart';

import 'book.dart';

/// The cart, with no widgets: it could run without Flutter's UI.
/// Every mutation ends with notifyListeners().
class Cart extends ChangeNotifier {
  final Map<Book, int> _qty = {};

  List<Book> get items => List.unmodifiable(_qty.keys);

  /// Distinct books, not copies.
  int get count => _qty.length;

  int qtyOf(Book b) => _qty[b] ?? 0;

  int get total =>
      _qty.entries.fold(0, (sum, e) => sum + e.key.price * e.value);

  /// The "no duplicates" rule lives here and nowhere else.
  /// Returns false and does nothing when the book is already in the cart.
  bool add(Book b) {
    if (_qty.containsKey(b)) return false;
    _qty[b] = 1;
    notifyListeners();
    return true;
  }

  void increment(Book b) {
    if (!_qty.containsKey(b)) return;
    _qty[b] = qtyOf(b) + 1;
    notifyListeners();
  }

  void remove(Book b) {
    _qty.remove(b);
    notifyListeners();
  }

  void clear() {
    _qty.clear();
    notifyListeners();
  }
}
