import 'package:dio/dio.dart';
import 'package:flowly/core/api_client.dart';
import 'package:flowly/core/constants.dart';
import 'package:flowly/data/models/cart_item_model.dart';

class OrderRepository {
  final _dio = ApiClient().dio;
  final baseUrl = AppConstants.baseUrl;
  Future<void> createOrder(
    String token,
    int customerId,
    List<CartItemModel> products,
  ) async {
    try {
      final jsonProducts = products
          .map((item) => {"id": item.product.id, "quantity": item.quantity})
          .toList();
      await _dio.post(
        "$baseUrl/api/orders",
        options: Options(headers: {"Authorization": "Bearer $token"}),
        data: {"customerId": customerId, "products": jsonProducts},
      );
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response!.data['message']);
      }
      throw Exception("Error creating order: $e");
    }
  }
}
