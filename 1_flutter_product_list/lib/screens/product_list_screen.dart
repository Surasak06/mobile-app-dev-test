import 'package:flutter/material.dart';

import '../controllers/product_list_controller.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/product_tile.dart';
import '../widgets/state_views.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({
    super.key,
    required this.service,
    this.debounceDuration = const Duration(milliseconds: 300),
  });

  final ProductService service;
  final Duration debounceDuration;

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late final ProductListController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = ProductListController(
      service: widget.service,
      debounceDuration: widget.debounceDuration,
    );
    _controller.load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _clearFilters() {
    _searchController.clear();
    _controller.clearFilters();
  }

  void _openDetail(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          if (widget.service case final MockProductService mock)
            _SimulateErrorMenu(
              enabled: mock.simulateError,
              onChanged: (value) {
                setState(() => mock.simulateError = value);
                _controller.load();
              },
            ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: _SearchField(
                  controller: _searchController,
                  onChanged: _controller.onSearchChanged,
                  onClear: () {
                    _searchController.clear();
                    _controller.clearSearch();
                  },
                ),
              ),
              if (_controller.status == LoadStatus.success)
                CategoryFilterBar(
                  categories: _controller.categories,
                  selected: _controller.selectedCategory,
                  onSelected: _controller.selectCategory,
                ),
              Expanded(child: _buildContent()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    switch (_controller.status) {
      case LoadStatus.loading:
        return const LoadingView();
      case LoadStatus.error:
        return ErrorView(
          message: _controller.errorMessage ?? 'Unknown error',
          onRetry: _controller.load,
        );
      case LoadStatus.success:
        final products = _controller.visibleProducts;
        if (products.isEmpty) {
          return EmptyView(
            onClearFilters:
                _controller.hasActiveFilters ? _clearFilters : null,
          );
        }
        return Column(
          children: [
            _ResultHeader(
              count: products.length,
              sort: _controller.sort,
              onSortChanged: _controller.setSort,
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductTile(
                    key: ValueKey(product.id),
                    product: product,
                    onTap: () => _openDetail(product),
                  );
                },
              ),
            ),
          ],
        );
    }
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextField(
          key: const Key('search_field'),
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search products',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    icon: const Icon(Icons.clear),
                    onPressed: onClear,
                  ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(28)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        );
      },
    );
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({
    required this.count,
    required this.sort,
    required this.onSortChanged,
  });

  final int count;
  final ProductSort sort;
  final ValueChanged<ProductSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 4, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              count == 1 ? '1 product' : '$count products',
              key: const Key('result_count'),
              style: theme.textTheme.labelLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          PopupMenuButton<ProductSort>(
            tooltip: 'Sort',
            initialValue: sort,
            onSelected: onSortChanged,
            itemBuilder: (_) => [
              for (final option in ProductSort.values)
                CheckedPopupMenuItem<ProductSort>(
                  value: option,
                  checked: option == sort,
                  child: Text(option.label),
                ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sort, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    sort == ProductSort.none ? 'Sort' : sort.label,
                    style: theme.textTheme.labelLarge,
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

class _SimulateErrorMenu extends StatelessWidget {
  const _SimulateErrorMenu({required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<bool>(
      tooltip: 'Demo options',
      onSelected: onChanged,
      itemBuilder: (_) => [
        CheckedPopupMenuItem<bool>(
          value: !enabled,
          checked: enabled,
          child: const Text('Simulate network error'),
        ),
      ],
    );
  }
}
