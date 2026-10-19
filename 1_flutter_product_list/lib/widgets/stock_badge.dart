import 'package:flutter/material.dart';

class StockBadge extends StatelessWidget {
  const StockBadge({super.key, required this.inStock});

  final bool inStock;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background =
        inStock ? scheme.primaryContainer : scheme.errorContainer;
    final foreground =
        inStock ? scheme.onPrimaryContainer : scheme.onErrorContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        inStock ? 'In stock' : 'Out of stock',
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: foreground, fontWeight: FontWeight.w600),
      ),
    );
  }
}
