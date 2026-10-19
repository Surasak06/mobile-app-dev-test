import 'package:flutter/material.dart';

/// Horizontally scrollable chips, so many/long categories never overflow.
class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<String> categories;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final options = <String?>[null, ...categories];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = options[index];
          return Center(
            child: ChoiceChip(
              key: Key('category_chip_${category ?? 'all'}'),
              label: Text(category ?? 'All'),
              selected: selected == category,
              onSelected: (_) => onSelected(category),
            ),
          );
        },
      ),
    );
  }
}
