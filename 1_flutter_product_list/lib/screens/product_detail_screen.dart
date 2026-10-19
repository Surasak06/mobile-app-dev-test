import 'package:flutter/material.dart';

import '../models/product.dart';
import '../utils/formatters.dart';
import '../widgets/stock_badge.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Product detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.name, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Chip(
                  avatar: const Icon(Icons.category_outlined, size: 18),
                  label: Text(product.category),
                ),
                StockBadge(inStock: product.inStock),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              formatPrice(product.price),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Text('Description', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              product.description.isEmpty
                  ? 'No description available.'
                  : product.description,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
