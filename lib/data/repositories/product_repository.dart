import 'package:dio/dio.dart';
import 'package:flowly/core/api_client.dart';
import 'package:flowly/core/constants.dart';
import 'package:flowly/data/models/product_model.dart';

class ProductRepository {
  final Dio _dio = ApiClient().dio;
  final String baseUrl = AppConstants.baseUrl;
  Future<List<ProductModel>> getProducts(String token) async {
    try {
      final response = await _dio.get(
        '$baseUrl/api/products',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      final List rawData = response.data['data'];
      final List<ProductModel> products = rawData
          .map((item) => ProductModel.fromJson(item))
          .toList();
      return products;
    } catch (e) {
      throw Exception("Failed to fetch products $e");
    }
  }

  // Update the method signature to accept the raw data needed
  Future<void> createProduct({
    required String token,
    required String name,
    required double costPrice,
    required double sellPrice,
    required int stock,
  }) async {
    try {
      final response = await _dio.post(
        // 1. Ensure this matches your Get request URL (remove /api if not used elsewhere)
        "$baseUrl/api/products",
        options: Options(headers: {"Authorization": "Bearer $token"}),
        // 2. Manually map the fields to match the Backend EXACTLY
        data: {
          "name": name,
          "costPrice": costPrice,
          "sellPrice": sellPrice,
          "stockQuantity":
              stock, // Backend expects 'stockQuantity', not 'stock'
        },
      );

      if (response.statusCode == 201) {
        print("Product Created Successfully");
      } else {
        // 3. Throw specific error so the UI can show it
        throw Exception("Failed: ${response.data['message']}");
      }
    } catch (e) {
      throw Exception("Error creating product: $e");
    }
  }

  Future<void> updateProduct(
    String token,
    int productId, {
    required String name,
    required int stock,
    required double sellPrice,
    required double costPrice,
  }) async {
    try {
      await _dio.put(
        "$baseUrl/api/products/$productId",
        options: Options(headers: {"Authorization": "Bearer $token"}),
        data: {
          "name": name,
          "stockQuantity": stock,
          "sellPrice": sellPrice,
          "costPrice": costPrice,
        },
      );
    } catch (e) {
      throw Exception("Error updating product: $e");
    }
  }

  Future<void> deleteProduct(String token, int productId) async {
    try {
      await _dio.delete(
        "$baseUrl/api/products/$productId",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
    } catch (e) {
      throw Exception("Error deleting product: $e");
    }
  }
}
