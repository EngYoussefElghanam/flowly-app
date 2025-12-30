import 'package:flowly/data/models/product_model.dart';
import 'package:flowly/data/models/cart_item_model.dart';

class OrderModel {
  final int id;
  final String status;
  final double totalAmount;
  final String? courierName;
  final String? notes;
  final String? trackingNumber;
  final String date;
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
    List<CartItemModel> parsedItems = [];

    if (json['products'] != null) {
      json['products'].forEach((pJson) {
        int qty = 1;
        // Extract quantity from the nested "orderItem" object
        if (pJson['orderItem'] != null &&
            pJson['orderItem']['quantity'] != null) {
          qty = pJson['orderItem']['quantity'];
        }

        // FIX: Use fromJson (which is robust) instead of fromMap
        final product = ProductModel.fromJson(pJson);

        parsedItems.add(CartItemModel(product: product, quantity: qty));
      });
    }

    return OrderModel(
      id: json['id'] ?? 0,
      status: json['status'] ?? 'NEW',
      // FIX: Use .toDouble() instead of double.parse()
      // double.parse() fails if the input is an Int (e.g., 200)
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
