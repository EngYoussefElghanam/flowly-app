class ProductModel {
  final int id;
  final String name;
  final double costPrice;
  final double sellPrice;
  final int stock;

  ProductModel({
    required this.id,
    required this.name,
    required this.costPrice,
    required this.sellPrice,
    required this.stock,
  });

  // ✅ ROBUST: Use this one for API calls
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      name: json['name'] ?? 'Unknown Item',
      // Safe conversion for prices
      sellPrice: (json['sellPrice'] ?? 0).toDouble(),
      costPrice: (json['costPrice'] ?? 0).toDouble(),
      // Handle key mismatch (stock vs stockQuantity)
      stock: (json['stockQuantity'] ?? json['stock'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'costPrice': costPrice,
      'sellPrice': sellPrice,
      'stock': stock,
    };
  }

  // ✅ FIXED: Made safe against Int/Double crashes
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int,
      name: map['name'] as String,
      // Fix: Don't use 'as double', use .toDouble()
      costPrice: (map['costPrice'] ?? 0).toDouble(),
      sellPrice: (map['sellPrice'] ?? 0).toDouble(),
      // Fix: Handle 'stock' or 'stockQuantity'
      stock: (map['stock'] ?? map['stockQuantity'] ?? 0) as int,
    );
  }
}
