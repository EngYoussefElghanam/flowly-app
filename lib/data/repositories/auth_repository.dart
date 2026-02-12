import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flowly/core/api_client.dart';
import 'package:flowly/core/constants.dart';
import 'package:flowly/data/models/staff_model.dart';
import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final Dio _dio = ApiClient().dio;
  final String baseUrl = AppConstants.baseUrl;

  // 1. LOGIN
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _dio.post(
        "$baseUrl/api/login",
        data: {'email': email, 'password': password},
      );

      final user = UserModel.fromJson(response.data);

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      final userJsonString = jsonEncode(user.toJson());
      await prefs.setString('user_data', userJsonString);

      return user;
    } catch (e) {
      // ✅ IMPROVEMENT: unified error handling helper
      throw _handleError(e);
    }
  }

  // 2. INITIATE SIGNUP (Step 1)
  Future<void> initiateSignUp(
    String name,
    String email,
    String password,
    String phone,
    String role,
    int? ownerId,
  ) async {
    try {
      // Handle the optional phone logic here if needed,
      // but backend handles null/empty strings safely now.
      final data = {
        "name": name,
        "email": email,
        "password": password,
        "phone": phone,
        "role": role,
        "ownerId": ownerId,
      };
      await _dio.post("$baseUrl/api/signup/initiate", data: data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 3. VERIFY SIGNUP (Step 2)
  Future<UserModel> verifySignUp(String code, String email) async {
    try {
      final response = await _dio.post(
        "$baseUrl/api/signup/verify",
        data: {"code": code, "email": email},
      );

      final user = UserModel.fromJson(response.data);

      // Save session
      final prefs = await SharedPreferences.getInstance();
      final userJsonString = jsonEncode(user.toJson());
      await prefs.setString('user_data', userJsonString);

      return user;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 4. AUTO LOGIN
  Future<UserModel?> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('user_data')) {
      return null;
    }

    final userString = prefs.getString('user_data');
    if (userString == null) return null;

    try {
      final Map<String, dynamic> userDecoded = jsonDecode(userString);
      return UserModel.fromJson(userDecoded);
    } catch (e) {
      // If JSON is corrupted, clear it and return null
      await prefs.remove('user_data');
      return null;
    }
  }

  // 5. LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  // 6. ADD STAFF
  Future<void> createEmployee({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String token,
    required int ownerId,
  }) async {
    try {
      final data = {
        "name": name,
        "email": email,
        "password": password,
        "phone": phone,
        "role": "EMPLOYEE",
        "ownerId": ownerId,
      };
      await _dio.post(
        "$baseUrl/api/signup/invite",
        options: Options(headers: {"Authorization": "Bearer $token"}),
        data: data,
      );

      // Note: The UI for adding staff will now need to ask the owner
      // to enter the code sent to the *employee's* email to verify them immediately.
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 7. VERIFY STAFF (Verify WITHOUT Login)
  Future<void> verifyStaff(String code, String email) async {
    try {
      // We call the same endpoint
      await _dio.post(
        "$baseUrl/api/signup/verify",
        data: {"code": code, "email": email},
      );
      // The Owner stays logged in.
    } catch (e) {
      throw _handleError(e);
    }
  }

  //8. GET employees
  Future<List<StaffModel>> getEmployees(String token) async {
    try {
      final response = await _dio.get(
        "$baseUrl/api/users/employees",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      final List employeesRaw = response.data['employees'];
      final List<StaffModel> employees = employeesRaw
          .map((item) => StaffModel.fromJson(item))
          .toList();
      return employees;
    } catch (e) {
      throw _handleError(e);
    }
  }

  //9. DELETE user
  Future<void> deleteUser(String token, int intendedId) async {
    try {
      await _dio.delete(
        "$baseUrl/api/users/$intendedId",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // --- HELPER ---
  // Keeps the code clean and handles Dio errors consistently
  Exception _handleError(dynamic e) {
    if (e is DioException) {
      if (e.response != null && e.response?.data != null) {
        final message = e.response?.data['message'];
        if (message != null) return Exception(message);
      }
      return Exception("Network error. Please check your connection.");
    }
    return Exception("An unexpected error occurred: $e");
  }
}
