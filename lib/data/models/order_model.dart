import 'package:flowly/data/models/product_model.dart';
import 'package:flowly/data/models/cart_item_model.dart'; // Import this!

class OrderModel {
  final int id;
  final String status;
  final double totalAmount;
  final String? courierName;
  final String? notes;
  final String? trackingNumber;
  final String date;
  // Use CartItemModel because it holds both Product AND Quantity bought
  final List<CartItemModel> items;

  OrderModel({
    required this.id,
    required this.status,
    required this.totalAmount,
    this.courierName,
    this.notes,
    this.trackingNumber,
    required this.date,
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // 1. Parse the Products List
    List<CartItemModel> parsedItems = [];

    if (json['products'] != null) {
      json['products'].forEach((pJson) {
        // Sequelize puts the quantity inside a nested object called "orderItem"
        // We need to extract it safely.
        int qty = 1;
        if (pJson['orderItem'] != null &&
            pJson['orderItem']['quantity'] != null) {
          qty = pJson['orderItem']['quantity'];
        }

        // Create the ProductModel from the JSON
        final product = ProductModel.fromMap(pJson);

        // Combine them into a CartItemModel
        parsedItems.add(CartItemModel(product: product, quantity: qty));
      });
    }

    return OrderModel(
      id: json['id'] ?? 0,
      status: json['status'] ?? 'NEW',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      courierName: json['courierName'],
      notes: json['notes'],
      trackingNumber: json['trackingNumber']?.toString(),
      date: json['createdAt'] != null
          ? json['createdAt'].toString().split('T')[0]
          : 'Unknown Date',
      items: parsedItems,
    );
  }
}
