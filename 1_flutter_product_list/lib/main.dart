import 'package:flutter/material.dart';

import 'screens/product_list_screen.dart';
import 'services/product_service.dart';

void main() {
  runApp(ProductListApp(service: MockProductService()));
}

class ProductListApp extends StatelessWidget {
  const ProductListApp({super.key, required this.service});

  final ProductService service;

  @override
  Widget build(BuildContext context) {
    const seed = Colors.indigo;
    return MaterialApp(
      title: 'Product List',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: ProductListScreen(service: service),
    );
  }
}
