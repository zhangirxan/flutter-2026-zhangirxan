# Practice 9 — notes

## Level 1: lifted state

**The total in the badge, the honest way.** One new value, passed by hand from the
owner down to the badge:

- constructors touched: **2** — `BooksScreen` (new `total` field) and `CartBadge`
  (new `total` field); plus the call site in `Shell` that computes and passes it;
- files touched: **3** — `lib/main.dart`, `lib/books_screen.dart`, `lib/cart_badge.dart`.

`BooksScreen` does not use `total` itself; it only carries it down to the badge.

**Rebuilds after one tap on Add:** **7** lines in the console — `BooksScreen build`
plus all **6** `row …` lines. `setState` in `Shell` marks everything under it dirty,
so one tap rebuilt the whole screen and every row.
