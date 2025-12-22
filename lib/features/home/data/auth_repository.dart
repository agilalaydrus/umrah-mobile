import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_client.dart';

class AuthRepository {
  final ApiClient _api;
  final FlutterSecureStorage _storage;

  AuthRepository(this._api, this._storage);

  /// 🔐 Login: Returns true if successful, throws String error otherwise.
  Future<void> login({required String phone, required String password}) async {
    try {
      final response = await _api.post('/login', data: {
        "phone_number": phone,
        "password": password,
      });

      // Validating Contract: { "token": "..." }
      final token = response.data['token'];
      if (token == null || token.toString().isEmpty) {
        throw "Server returned empty token.";
      }

      // Securely store the token
      await _storage.write(key: 'token', value: token);
      
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      throw e.toString();
    }
  }

  /// 📝 Register: Handles Admin, Mutawwif, or Jamaah registration
  Future<void> register({
    required String fullName,
    required String phone,
    required String password,
    required String role, // "ADMIN", "MUTAWWIF", "JAMAAH"
  }) async {
    try {
      await _api.post('/register', data: {
        "full_name": fullName,
        "phone_number": phone,
        "password": password,
        "role": role, 
      });
      // 201 Created -> Success. No return value needed.
    } on DioException catch (e) {
      throw _parseDioError(e);
    }
  }

  /// 🧹 Logout: Clears storage
  Future<void> logout() async {
    await _storage.deleteAll();
  }

  // Production-Grade Error Parsing
  String _parseDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout || 
        e.type == DioExceptionType.receiveTimeout) {
      return "Connection timed out. Check your internet.";
    }
    
    if (e.response != null) {
      // Backend Standard: { "error": "User already exists" }
      final errorData = e.response?.data;
      if (errorData is Map && errorData.containsKey('error')) {
        return errorData['error'];
      }
      return "Server Error: ${e.response?.statusCode}";
    }
    
    return "Network Error. Cannot connect to server.";
  }
}