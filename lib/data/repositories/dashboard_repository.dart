import 'package:dio/dio.dart';
import 'package:flowly/core/api_client.dart';
import 'package:flowly/core/constants.dart';
import 'package:flowly/data/models/dashboard_stats_model.dart';

class DashboardRepository {
  final Dio _dio = ApiClient().dio;
  final String baseUrl = AppConstants.baseUrl;
  Future<DashboardStatsModel> getStats(String token) async {
    try {
      final response = await _dio.get(
        "$baseUrl/api/dashboard",
        options: Options(headers: {"Authorization": "bearer $token"}),
      );
      final dashStats = DashboardStatsModel.fromJson(response.data);
      return dashStats;
    } catch (e) {
      throw Exception("Error getting Stats $e");
    }
  }
}
