import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flowly/core/api_client.dart';
import 'package:flowly/core/constants.dart';
import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final Dio _dio = ApiClient().dio;
  final String baseUrl = AppConstants.baseUrl;
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _dio.post(
        "$baseUrl/api/login",
        data: {'email': email, 'password': password},
      );
      //save
      final user = UserModel.fromJson(response.data);
      final prefs = await SharedPreferences.getInstance();
      final userJsonString = jsonEncode(user.toJson());
      await prefs.setString('user_data', userJsonString);
      return user;
    } catch (e) {
      throw Exception("Login Failed $e");
    }
  }

  //sign up
  Future<UserModel> signUp(
    String name,
    String email,
    String password,
    String phone,
    String role,
    int? ownerId,
  ) async {
    try {
      final data = {
        "name": name,
        "email": email,
        "password": password,
        "phone": phone,
        "role": role,
        "ownerId": ownerId,
      };
      final response = await _dio.post("$baseUrl/api/signup", data: data);
      final user = UserModel.fromJson(response.data);
      final prefs = await SharedPreferences.getInstance();
      final userJsonString = jsonEncode(user.toJson());
      await prefs.setString('user_data', userJsonString);
      return user;
    } catch (e) {
      if (e is DioException) {
        if (e.response != null && e.response!.data != null) {
          throw Exception(e.response!.data['message'] ?? "Sign up failed");
        }
      }
      throw Exception("Network error or server unreachable");
    }
  }

  //Auto login retreive the data
  Future<UserModel?> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('user_data')) {
      return null;
    }
    final user = prefs.getString('user_data');
    final userDecoded = jsonDecode(user!);
    final userFinal = UserModel.fromJson(userDecoded);
    return userFinal;
  }

  //logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }
}
