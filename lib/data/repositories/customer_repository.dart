import 'package:dio/dio.dart';
import 'package:flowly/core/api_client.dart';
import 'package:flowly/core/constants.dart';
import 'package:flowly/data/models/customer_model.dart';

class CustomerRepository {
  final Dio _dio = ApiClient().dio;
  final String baseUrl = AppConstants.baseUrl;
  Future<List<CustomerModel>> getCustomers(String token) async {
    try {
      final response = await _dio.get(
        "$baseUrl/api/customers",
        options: Options(headers: {"Authorization": "bearer $token"}),
      );
      final List rawData = response.data['data'];
      final List<CustomerModel> customers = rawData
          .map((item) => CustomerModel.fromJson(item))
          .toList();
      return customers;
    } catch (e) {
      throw Exception("Failed to fetch Customers $e");
    }
  }

  Future<CustomerModel> getCustomerDetails(int customerId, String token) async {
    try {
      final response = await _dio.get(
        "$baseUrl/api/customers/$customerId",
        options: Options(headers: {"Authorization": "bearer $token"}),
      );
      final dynamic rawJson = response.data['data'];
      final CustomerModel customer = CustomerModel.fromJson(rawJson);
      return customer;
    } catch (e) {
      throw Exception("Error Fetching Customer : $e");
    }
  }

  Future<void> createCustomer({
    required String token,
    required String name,
    required String phone,
    required String city,
    required String address,
  }) async {
    try {
      await _dio.post(
        "$baseUrl/api/customers",
        options: Options(headers: {"Authorization": "bearer $token"}),
        data: {"name": name, "phone": phone, "city": city, "address": address},
      );
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response!.data['message']);
      }
      throw Exception("Failed to add customer: $e");
    }
  }
}
