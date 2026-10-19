import 'package:flutter_test/flutter_test.dart';
import 'package:product_list/services/product_service.dart';
import 'package:product_list/utils/formatters.dart';

void main() {
  group('parseProducts', () {
    test('parses valid JSON into typed products', () {
      final products = parseProducts(
        '[{"id": 1, "name": "Mouse", "price": 890, "category": "Accessories",'
        ' "inStock": true, "description": "Nice"}]',
      );

      expect(products, hasLength(1));
      expect(products.first.name, 'Mouse');
      expect(products.first.price, 890.0);
      expect(products.first.inStock, isTrue);
    });

    test('throws FormatException for invalid fields', () {
      expect(
        () => parseProducts('[{"id": "1", "name": "Mouse"}]'),
        throwsFormatException,
      );
    });
  });

  group('formatPrice', () {
    test('formats Thai Baht with thousands separators', () {
      expect(formatPrice(0), '฿0.00');
      expect(formatPrice(890), '฿890.00');
      expect(formatPrice(1890), '฿1,890.00');
      expect(formatPrice(1234567.5), '฿1,234,567.50');
    });
  });
}
