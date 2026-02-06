import 'package:dio/dio.dart';
import 'package:flowly/core/api_client.dart';
import 'package:flowly/core/constants.dart';

class SettingsRepository {
  final _dio = ApiClient().dio;
  final baseUrl = AppConstants.baseUrl;
  Future<Map<String, int>> getSettings(String token) async {
    try {
      final response = await _dio.get(
        "$baseUrl/api/settings",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      final Map<String, dynamic> rawData = response.data;
      return {
        'inactiveThreshold': rawData['inactiveThreshold'] as int,
        'vipOrderThreshold': rawData['vipOrderThreshold'] as int,
        'lowStockThreshold': rawData['lowStockThreshold'] as int,
      };
    } catch (e) {
      throw Exception("Error happened fetching settings $e");
    }
  }

  Future<void> updateSettings(
    String token,
    int inactiveThreshold,
    int vipOrderThreshold,
    int lowStockThreshold,
  ) async {
    try {
      await _dio.put(
        "$baseUrl/api/settings",
        options: Options(headers: {"Authorization": "Bearer $token"}),
        data: {
          "inactiveThreshold": inactiveThreshold,
          "vipOrderThreshold": vipOrderThreshold,
          "lowStockThreshold": lowStockThreshold,
        },
      );
    } catch (e) {
      throw Exception("Error happened while updating settings $e");
    }
  }
}
