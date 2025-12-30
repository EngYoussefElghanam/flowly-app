import 'package:dio/dio.dart';
import 'session_manager.dart'; // Import the radio station

class ApiClient {
  // Singleton pattern (One instance for the whole app)
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio dio;

  ApiClient._internal() {
    dio = Dio();

    // Add the "Interceptor" (The Traffic Cop)
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, handler) {
          // ⚠️ CHECK: Is it a 401 Unauthorized error?
          if (e.response?.statusCode == 401) {
            // 🚨 BROADCAST: "Token Expired!"
            SessionManager.expireSession();
          }
          return handler.next(e); // Continue with the error
        },
      ),
    );
  }
}
