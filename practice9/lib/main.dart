import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'books_screen.dart';
import 'cart_screen.dart';
import 'models/cart.dart';

void main() =>
    runApp(ChangeNotifierProvider(create: (_) => Cart(), child: const Shell()));

/// Only builds the app; the cart lives in the provider above it.
class Shell extends StatelessWidget {
  const Shell({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
    ),
    routes: {
      '/': (_) => const BooksScreen(),
      '/cart': (_) => const CartScreen(),
    },
  );
}
