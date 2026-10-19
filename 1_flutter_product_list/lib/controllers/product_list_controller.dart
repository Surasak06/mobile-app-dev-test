import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../services/product_service.dart';

enum LoadStatus { loading, error, success }

enum ProductSort {
  none('Default'),
  priceLowToHigh('Price: Low to High'),
  priceHighToLow('Price: High to Low');

  const ProductSort(this.label);
  final String label;
}

/// Holds loading state, search query, category filter and sort order.
///
/// Search and category filters are combined (AND), e.g. "keyboard" within
/// "Accessories" only.
class ProductListController extends ChangeNotifier {
  ProductListController({
    required ProductService service,
    this.debounceDuration = const Duration(milliseconds: 300),
  }) : _service = service;

  final ProductService _service;
  final Duration debounceDuration;

  LoadStatus _status = LoadStatus.loading;
  String? _errorMessage;
  List<Product> _products = const [];
  String _query = '';
  String? _selectedCategory;
  ProductSort _sort = ProductSort.none;
  Timer? _debounce;
  bool _disposed = false;

  LoadStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get query => _query;
  String? get selectedCategory => _selectedCategory;
  ProductSort get sort => _sort;
  bool get hasActiveFilters => _query.isNotEmpty || _selectedCategory != null;

  List<String> get categories {
    final unique = _products.map((p) => p.category).toSet().toList()..sort();
    return unique;
  }

  List<Product> get visibleProducts {
    final normalizedQuery = _query.toLowerCase();
    final filtered = _products.where((product) {
      final matchesQuery = normalizedQuery.isEmpty ||
          product.name.toLowerCase().contains(normalizedQuery);
      final matchesCategory =
          _selectedCategory == null || product.category == _selectedCategory;
      return matchesQuery && matchesCategory;
    }).toList();

    switch (_sort) {
      case ProductSort.none:
        break;
      case ProductSort.priceLowToHigh:
        filtered.sort((a, b) => a.price.compareTo(b.price));
      case ProductSort.priceHighToLow:
        filtered.sort((a, b) => b.price.compareTo(a.price));
    }
    return filtered;
  }

  Future<void> load() async {
    _status = LoadStatus.loading;
    _errorMessage = null;
    _notify();

    try {
      final products = await _service.fetchProducts();
      if (_disposed) return;
      _products = products;
      _status = LoadStatus.success;
    } on ProductServiceException catch (e) {
      if (_disposed) return;
      _status = LoadStatus.error;
      _errorMessage = e.message;
    } catch (_) {
      if (_disposed) return;
      _status = LoadStatus.error;
      _errorMessage = 'Something went wrong. Please try again.';
    }
    _notify();
  }

  /// Debounced: the filter is applied after the user stops typing.
  void onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(debounceDuration, () => _applyQuery(value));
  }

  /// Applies immediately (used by the clear button).
  void clearSearch() {
    _debounce?.cancel();
    _applyQuery('');
  }

  void selectCategory(String? category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _notify();
  }

  void setSort(ProductSort sort) {
    if (_sort == sort) return;
    _sort = sort;
    _notify();
  }

  void clearFilters() {
    _debounce?.cancel();
    _query = '';
    _selectedCategory = null;
    _notify();
  }

  void _applyQuery(String value) {
    final trimmed = value.trim();
    if (trimmed == _query) return;
    _query = trimmed;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    super.dispose();
  }
}
