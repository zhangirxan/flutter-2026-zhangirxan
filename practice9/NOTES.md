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

## Level 2: a model with no widgets

Before `runApp`, with no widget in sight: add two books, add the first again, remove
the first → the console printed **`1 items, 3100 ₸`**.

`cart.items.add(books[0])` from outside throws
**`Unsupported operation: Cannot add to an unmodifiable list`** — only `add` can change
the cart, and `add` always notifies.

## Level 3: provider — the loud error and the silent one

**Loud** — `context.watch<Cart>()` inside the Add button's `onPressed`:

> Tried to listen to a value exposed with provider, from outside of the widget tree.
> This is likely caused by an event handler (like a button's onPressed) that called
> Provider.of without passing `listen: false`.
> To fix, write: `Provider.of<Cart>(context, listen: false);`

**Silent** — `context.read<Cart>().count` inside the badge's `build`: no error, no
warning, it compiles and runs, and the badge stays at **0 forever** — nobody said
"I depend on the cart", so nobody rebuilds it.

`watch` is a verb of `build`, `read` is a verb of `onPressed`.

## Level 4: scope — rebuild counts

Three presses on **+** on a cart row (the count does not change), then one remove:

| Badge subscribes with | `badge build` on 3 × + | on remove |
|---|---|---|
| `context.watch<Cart>().count` | **3** | 1 |
| `context.select<Cart, int>((c) => c.count)` | **0** | 1 |

Same model, same taps, one line changed in one widget.

Moving the subscription up on purpose — `context.watch<Cart>()` in `BooksScreen.build` —
made the Books rows rebuild **18** times on 3 × + (6 rows × 3), on a screen the user
is not even looking at. Subscribe where the value is shown, not where it is convenient.

The Cart total line is a `Consumer<Cart>` whose `child` (the icon and the word
"Total") is built **once**: `total label build` printed **0** times on 3 × +.

(Measured with `debugPrint` lines counted in a widget test, see
`test/widget_test.dart`.)

## Where does it live?

| Value | Home | Why |
|---|---|---|
| The cart | **provided** | Two routes and the badge read it; it must outlive both screens. One `ChangeNotifierProvider` above `MaterialApp`. |
| The search text in the Books AppBar | **ephemeral** | Only the Books screen uses it; a `TextEditingController` in that screen's `State`. |
| Whether the Cart total is expanded or collapsed | **ephemeral** | A purely visual toggle of one widget on one screen; nobody else cares. |
| The theme mode of a dark-mode switch | **lifted** (or provided) | It is read by `MaterialApp`, so it has to live above it — in the `State` of the widget that builds `MaterialApp`, passed down to the switch with a callback. |
