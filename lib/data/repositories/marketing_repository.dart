import 'package:dio/dio.dart';
import 'package:flowly/core/api_client.dart';
import 'package:flowly/core/constants.dart';
import 'package:flowly/data/models/marketing_opportunity.dart';

class MarketingRepository {
  final Dio _dio = ApiClient().dio;
  final String baseUrl = AppConstants.baseUrl;
  Future<List<MarketingOpportunity>> fetchOpportunities(String token) async {
    try {
      final response = await _dio.get(
        '$baseUrl/marketing/opportunities',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      final List data = response.data['opportunities'];
      final List<MarketingOpportunity> list = data
          .map((item) => MarketingOpportunity.fromJson(item))
          .toList();
      return list;
    } catch (e) {
      throw Exception("Error to fetch opportunities $e");
    }
  }

  Future<void> sendAction(
    String token,
    String action,
    int opportunityId,
  ) async {
    try {
      await _dio.post(
        '$baseUrl/marketing/action/$opportunityId',
        options: Options(headers: {"Authorization": "Bearer $token"}),
        data: {"action": action},
      );
    } catch (e) {
      throw Exception("Error to send action $e");
    }
  }
}
