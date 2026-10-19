import 'dart:convert';

import '../models/product.dart';

/// Thrown when products cannot be loaded. [message] is safe to show to users.
class ProductServiceException implements Exception {
  const ProductServiceException(this.message);

  final String message;

  @override
  String toString() => 'ProductServiceException: $message';
}

/// Source of products. Swap the implementation for a real HTTP client later.
abstract interface class ProductService {
  Future<List<Product>> fetchProducts();
}

/// Simulates a network call with a JSON payload.
///
/// Toggle [simulateError] (from the app bar menu) to see the Error state and
/// the Retry button.
class MockProductService implements ProductService {
  MockProductService({this.delay = const Duration(milliseconds: 800)});

  final Duration delay;
  bool simulateError = false;

  @override
  Future<List<Product>> fetchProducts() async {
    await Future<void>.delayed(delay);
    if (simulateError) {
      throw const ProductServiceException(
        'Could not load products. Please check your connection and try again.',
      );
    }
    return parseProducts(_mockJson);
  }
}

/// Parses a JSON array into typed [Product]s.
List<Product> parseProducts(String source) {
  final Object? decoded = jsonDecode(source);
  if (decoded is! List<Object?>) {
    throw const FormatException('Expected a JSON array of products');
  }
  final products = <Product>[];
  for (final Object? item in decoded) {
    if (item is! Map<String, Object?>) {
      throw const FormatException('Expected a JSON object for each product');
    }
    products.add(Product.fromJson(item));
  }
  return products;
}

const String _mockJson = '''
[
  {"id": 1, "name": "Mechanical Keyboard", "price": 2490, "category": "Accessories", "inStock": true, "description": "Hot-swappable mechanical keyboard with brown switches and RGB backlight."},
  {"id": 2, "name": "Wireless Mouse", "price": 890, "category": "Accessories", "inStock": true, "description": "Ergonomic wireless mouse with silent clicks and 70-day battery life."},
  {"id": 3, "name": "Compact Wireless Keyboard for Tablets, Phones and Laptops with Multi-Device Bluetooth Pairing", "price": 1290, "category": "Accessories", "inStock": false, "description": "Slim keyboard that switches between three paired devices."},
  {"id": 4, "name": "27\\" 4K Monitor", "price": 11900, "category": "Displays", "inStock": true, "description": "IPS panel, 99% sRGB, USB-C 65W power delivery."},
  {"id": 5, "name": "Portable Monitor 15.6\\"", "price": 5490, "category": "Displays", "inStock": false, "description": "Lightweight USB-C portable display for working on the go."},
  {"id": 6, "name": "Noise Cancelling Headphones", "price": 7990, "category": "Audio", "inStock": true, "description": "Over-ear headphones with adaptive ANC and 30-hour battery."},
  {"id": 7, "name": "Bluetooth Speaker", "price": 1990, "category": "Audio", "inStock": true, "description": "Waterproof IP67 speaker with deep bass."},
  {"id": 8, "name": "USB Condenser Microphone", "price": 3290, "category": "Audio", "inStock": false, "description": "Cardioid microphone for streaming and podcasts."},
  {"id": 9, "name": "Laptop Stand", "price": 990, "category": "Office", "inStock": true, "description": "Adjustable aluminium stand that improves posture."},
  {"id": 10, "name": "Ergonomic Office Chair", "price": 8900, "category": "Office", "inStock": true, "description": "Mesh back with adjustable lumbar support and armrests."},
  {"id": 11, "name": "Keyboard Wrist Rest", "price": 450, "category": "Office", "inStock": true, "description": "Memory-foam wrist rest for full-size keyboards."},
  {"id": 12, "name": "USB-C Hub 7-in-1", "price": 1590, "category": "Accessories", "inStock": true, "description": "HDMI 4K, 3x USB-A, SD/microSD and 100W pass-through charging."}
]
''';
