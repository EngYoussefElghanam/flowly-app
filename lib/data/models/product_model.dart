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
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'] ?? 'Unknown Item',
      // Safety: Handle if API sends Int or Double
      sellPrice: double.parse((json['sellPrice'] ?? 0).toString()),
      costPrice: double.parse((json['costPrice'] ?? 0).toString()),
      stock: int.parse(
        (json['stockQuantity'] ?? 0).toString(),
      ), // Check your DB column name!
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sellPrice': sellPrice,
      'costPrice': costPrice,
      'stockQuantity': stock,
    };
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

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int,
      name: map['name'] as String,
      costPrice: map['costPrice'] as double,
      sellPrice: map['sellPrice'] as double,
      stock: map['stock'] as int,
    );
  }
}
