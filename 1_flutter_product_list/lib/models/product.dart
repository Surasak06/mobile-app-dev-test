/// A product shown in the list. All fields are strongly typed; JSON is
/// validated in [Product.fromJson] so no `dynamic` leaks past parsing.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.inStock,
    required this.description,
  });

  final int id;
  final String name;
  final double price;
  final String category;
  final bool inStock;
  final String description;

  factory Product.fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final name = json['name'];
    final price = json['price'];
    final category = json['category'];
    final inStock = json['inStock'];
    final description = json['description'];

    if (id is! int ||
        name is! String ||
        price is! num ||
        category is! String ||
        inStock is! bool) {
      throw FormatException('Invalid product JSON: $json');
    }

    return Product(
      id: id,
      name: name,
      price: price.toDouble(),
      category: category,
      inStock: inStock,
      description: description is String ? description : '',
    );
  }

  @override
  bool operator ==(Object other) => other is Product && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
