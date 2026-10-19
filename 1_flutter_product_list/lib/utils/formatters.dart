/// Formats a price as Thai Baht, e.g. 2490 -> "฿2,490.00".
String formatPrice(double value) {
  final fixed = value.abs().toStringAsFixed(2);
  final parts = fixed.split('.');
  final whole = parts[0];
  final buffer = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    final remaining = whole.length - i;
    buffer.write(whole[i]);
    if (remaining > 1 && remaining % 3 == 1) buffer.write(',');
  }
  final sign = value < 0 ? '-' : '';
  return '$sign฿$buffer.${parts[1]}';
}
