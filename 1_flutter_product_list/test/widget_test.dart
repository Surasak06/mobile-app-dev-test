import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_list/models/product.dart';
import 'package:product_list/screens/product_list_screen.dart';
import 'package:product_list/services/product_service.dart';

const _products = [
  Product(
    id: 1,
    name: 'Mechanical Keyboard',
    price: 2490,
    category: 'Accessories',
    inStock: true,
    description: '',
  ),
  Product(
    id: 2,
    name: 'Wireless Mouse',
    price: 890,
    category: 'Accessories',
    inStock: true,
    description: '',
  ),
  Product(
    id: 3,
    name: 'Keyboard Wrist Rest',
    price: 450,
    category: 'Office',
    inStock: false,
    description: '',
  ),
  Product(
    id: 4,
    name: 'Bluetooth Speaker',
    price: 1990,
    category: 'Audio',
    inStock: true,
    description: '',
  ),
];

/// Fails [failuresBeforeSuccess] times, then returns [_products].
class FakeProductService implements ProductService {
  FakeProductService({this.failuresBeforeSuccess = 0});

  int failuresBeforeSuccess;
  int calls = 0;

  @override
  Future<List<Product>> fetchProducts() async {
    calls++;
    if (failuresBeforeSuccess > 0) {
      failuresBeforeSuccess--;
      throw const ProductServiceException('Network error');
    }
    return _products;
  }
}

const _debounce = Duration(milliseconds: 300);

Future<void> _pumpScreen(WidgetTester tester, ProductService service) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ProductListScreen(service: service, debounceDuration: _debounce),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _search(WidgetTester tester, String text) async {
  await tester.enterText(find.byKey(const Key('search_field')), text);
  await tester.pump(_debounce + const Duration(milliseconds: 50));
}

void main() {
  testWidgets('shows all products after loading', (tester) async {
    await _pumpScreen(tester, FakeProductService());

    expect(find.text('Mechanical Keyboard'), findsOneWidget);
    expect(find.text('Bluetooth Speaker'), findsOneWidget);
    expect(find.text('4 products'), findsOneWidget);
  });

  testWidgets('search filters products by name (case-insensitive)',
      (tester) async {
    await _pumpScreen(tester, FakeProductService());

    await _search(tester, 'keyboard');

    expect(find.text('Mechanical Keyboard'), findsOneWidget);
    expect(find.text('Keyboard Wrist Rest'), findsOneWidget);
    expect(find.text('Wireless Mouse'), findsNothing);
    expect(find.text('2 products'), findsOneWidget);
  });

  testWidgets('search and category filter work together', (tester) async {
    await _pumpScreen(tester, FakeProductService());

    await tester.tap(find.byKey(const Key('category_chip_Accessories')));
    await tester.pump();
    await _search(tester, 'Keyboard');

    expect(find.text('Mechanical Keyboard'), findsOneWidget);
    expect(find.text('Keyboard Wrist Rest'), findsNothing); // Office
    expect(find.text('1 product'), findsOneWidget);
  });

  testWidgets('shows empty state when nothing matches', (tester) async {
    await _pumpScreen(tester, FakeProductService());

    await _search(tester, 'zzz-not-found');

    expect(find.text('No products found'), findsOneWidget);

    await tester.tap(find.text('Clear filters'));
    await tester.pump();
    expect(find.text('Mechanical Keyboard'), findsOneWidget);
  });

  testWidgets('shows error with Retry, and Retry reloads data', (tester) async {
    final service = FakeProductService(failuresBeforeSuccess: 1);
    await _pumpScreen(tester, service);

    expect(find.text('Network error'), findsOneWidget);
    expect(find.byKey(const Key('retry_button')), findsOneWidget);
    expect(find.text('Mechanical Keyboard'), findsNothing);

    await tester.tap(find.byKey(const Key('retry_button')));
    await tester.pumpAndSettle();

    expect(service.calls, 2);
    expect(find.text('Network error'), findsNothing);
    expect(find.text('Mechanical Keyboard'), findsOneWidget);
  });

  testWidgets('long product names do not overflow on a narrow screen',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final service = _SingleProductService(
      const Product(
        id: 99,
        name: 'An extremely long product name that would definitely overflow '
            'a narrow phone screen if it were not constrained properly',
        price: 1234567,
        category: 'A very long category name for testing purposes',
        inStock: true,
        description: '',
      ),
    );
    await _pumpScreen(tester, service);

    expect(tester.takeException(), isNull);
  });
}

class _SingleProductService implements ProductService {
  _SingleProductService(this.product);

  final Product product;

  @override
  Future<List<Product>> fetchProducts() async => [product];
}
