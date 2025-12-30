import 'package:flowly/data/models/order_model.dart';

class CustomerModel {
  final int id;
  final String name;
  final String phone;
  final String city;
  final String address;
  final List<OrderModel> orders;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.city,
    required this.address,
    this.orders = const [],
  });
  // Factory to parse JSON from Backend
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    var orderList = <OrderModel>[];

    // Check if 'orders' exists in the JSON and map it
    if (json['orders'] != null) {
      json['orders'].forEach((v) {
        orderList.add(OrderModel.fromJson(v));
      });
    }
    return CustomerModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      city: json['city'] ?? '',
      address: json['address'] ?? '',
      orders: orderList,
    );
  }

  // To send JSON (if needed later)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'city': city,
      'address': address,
      'orders': orders,
    };
  }
}
