import 'package:dio/dio.dart';
import 'package:flowly/core/api_client.dart';
import 'package:flowly/core/constants.dart';
import 'package:flowly/data/models/cart_item_model.dart';
import 'package:flowly/data/models/order_model.dart';

class OrderRepository {
  final _dio = ApiClient().dio;
  final baseUrl = AppConstants.baseUrl;

  // 1. IMPROVEMENT: Return 'int' (Order ID) instead of void
  Future<int> createOrder(
    String token,
    int customerId,
    List<CartItemModel> products,
  ) async {
    try {
      final jsonProducts = products
          .map((item) => {"id": item.product.id, "quantity": item.quantity})
          .toList();

      final response = await _dio.post(
        "$baseUrl/api/orders",
        options: Options(headers: {"Authorization": "Bearer $token"}),
        data: {"customerId": customerId, "products": jsonProducts},
      );

      // Return the new Order ID (Backend sends { message: "...", orderId: 123 })
      return response.data['orderId'];
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response!.data['message']);
      }
      throw Exception("Error creating order: $e");
    }
  }

  Future<OrderModel> getOrderDetails(String token, int orderId) async {
    try {
      final response = await _dio.get(
        "$baseUrl/api/orders/$orderId",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      return OrderModel.fromJson(response.data);
    } catch (e) {
      // 2. IMPROVEMENT: Specific error handling here too
      if (e is DioException && e.response != null) {
        throw Exception(e.response!.data['message'] ?? "Failed to fetch order");
      }
      throw Exception("Error fetching details: $e");
    }
  }

  // 3. IMPROVEMENT: Add optional tracking number
  Future<void> updateStatus(
    String token,
    int orderId,
    String newStatus, {
    String? trackingNumber, // Optional argument
  }) async {
    try {
      final Map<String, dynamic> body = {"status": newStatus};
      if (trackingNumber != null) {
        body['trackingNumber'] = trackingNumber;
      }

      await _dio.patch(
        "$baseUrl/api/orders/$orderId",
        options: Options(headers: {"Authorization": "Bearer $token"}),
        data: body,
      );
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(
          e.response!.data['message'] ?? "Failed to update status",
        );
      }
      throw Exception("Error updating status: $e");
    }
  }
}
