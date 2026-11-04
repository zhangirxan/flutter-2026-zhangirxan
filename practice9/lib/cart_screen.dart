import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  /// The question lives in the widget; the clearing lives in the model.
  Future<void> _clear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear the cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    context.read<Cart>().clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          IconButton(
            tooltip: 'Clear cart',
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _clear(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<Cart>(
              builder: (context, cart, _) => ListView(
                children: [
                  for (final b in cart.items)
                    ListTile(
                      title: Text(b.title),
                      subtitle: Text('${b.price} ₸  ×${cart.qtyOf(b)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'One more',
                            icon: const Icon(Icons.add),
                            onPressed: () => cart.increment(b),
                          ),
                          IconButton(
                            tooltip: 'Remove',
                            icon: const Icon(Icons.close),
                            onPressed: () => cart.remove(b),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Consumer<Cart>(
              // child is built once and handed back on every notify.
              child: const _TotalLabel(),
              builder: (context, cart, child) => Row(
                children: [
                  child!,
                  const Spacer(),
                  Text(
                    '${cart.total} ₸',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalLabel extends StatelessWidget {
  const _TotalLabel();

  @override
  Widget build(BuildContext context) {
    debugPrint('total label build');
    return Row(
      children: [
        const Icon(Icons.receipt_long),
        const SizedBox(width: 8),
        Text('Total', style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}
