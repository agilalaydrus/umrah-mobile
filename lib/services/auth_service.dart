import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // Use localhost for Web/iOS, or 10.0.2.2 for Android
  final String baseUrl = "http://10.0.2.2:3000/api"; 
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  Future<String?> login(String phone, String password) async {
    try {
      final response = await _dio.post('$baseUrl/login', data: {
        "phone_number": phone,
        "password": password,
      });

      if (response.statusCode == 200) {
        String token = response.data['token'];
        // Save token securely
        await _storage.write(key: 'jwt_token', value: token);
        return null; // Success
      }
      return "Unknown Error";
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response?.data['error'] ?? "Login Failed";
      }
      return "Connection Error. Is Docker running?";
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

Future<String?> register(String name, String phone, String password, String role) async {
    try {
      await _dio.post('$baseUrl/register', data: {
        "full_name": name,
        "phone_number": phone,
        "password": password,
        "role": role
      });
      return null; 
    } on DioException catch (e) {
      return e.response?.data['error'] ?? "Registration Failed";
    }
  }

  // Update method ini di AuthService

  Future<String> forgotPassword(String phone) async {
    try {
      final res = await _dio.post('$baseUrl/forgot-password', data: {
        "phone_number": phone
      });

      // --- DEBUGGING ---
      // Lihat apa yang sebenarnya dikirim oleh Server di Terminal
      print("Status Code: ${res.statusCode}");
      print("Data Type: ${res.data.runtimeType}"); 
      print("Data Content: ${res.data}"); 
      // -----------------

      // Cek apakah data benar-benar Map (JSON Object)
      if (res.data is Map<String, dynamic>) {
         return "OTP Sent: ${res.data['debug_otp']}"; 
      } 
      
      // Jika ternyata String (mungkin JSON string mentah), kita return error
      return "Error: Server returned unexpected data format";

    } on DioException catch (e) {
      // Penanganan Error yang Lebih Aman
      if (e.response != null && e.response!.data is Map) {
        // Jika error berupa JSON (misal: {"error": "User not found"})
        throw e.response!.data['error'] ?? "Failed";
      } else {
        // Jika error berupa String/HTML (misal: 500 Internal Server Error)
        print("Server Error Raw: ${e.response?.data}");
        throw "Server Error: ${e.response?.statusCode}. Cek Terminal.";
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String?> resetPassword(String phone, String otp, String newPass) async {
    try {
      await _dio.post('$baseUrl/reset-password', data: {
        "phone_number": phone,
        "otp": otp,
        "new_password": newPass
      });
      return null; 
    } on DioException catch (e) {
      return e.response?.data['error'] ?? "Failed";
    }
  }
}