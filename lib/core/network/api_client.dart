import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart'; // [NEW] Import Logger

class ApiClient {
  // Production Tip: Use environmental variables for this URL
  static const String _baseUrl = 'https://10.0.2.2/api'; 
  
  final Dio _dio;
  final FlutterSecureStorage _storage;
  
  // [NEW] Static logger instance (Reusable & Configurable)
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // Don't print the stack trace for simple logs
      errorMethodCount: 5, // Do print stack trace for errors
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  ApiClient(this._storage) 
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        )) {
    
    // 1. SSL Handling (Dev Only)
    if (kDebugMode) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }

    // 2. Interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          // [NEW] Proper Debug Logging
          if (kDebugMode) {
            _logger.d("🚀 REQUEST [${options.method}] => ${options.path}");
          }
          return handler.next(options);
        },
        
        onResponse: (response, handler) {
          if (kDebugMode) {
            _logger.i("✅ RESPONSE [${response.statusCode}] => ${response.requestOptions.path}");
          }
          return handler.next(response);
        },

        onError: (DioException e, handler) async {
          // [NEW] Proper Error Logging
          _logger.e("❌ ERROR [${e.response?.statusCode}] => ${e.requestOptions.path}", error: e.error, stackTrace: e.stackTrace);

          if (e.response?.statusCode == 401) {
            await _storage.deleteAll();
            _logger.w("🚨 Session Expired. Logout triggered.");
          }
          return handler.next(e);
        },
      ),
    );
  }

  // Type-Safe Methods
  Future<Response> post(String path, {dynamic data}) async {
    return _dio.post(path, data: data);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) async {
    return _dio.get(path, queryParameters: queryParams);
  }
}