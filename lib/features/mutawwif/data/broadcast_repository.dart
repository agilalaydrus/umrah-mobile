import 'package:dio/dio.dart';
import 'package:umrah_app/core/network/api_client.dart';

class BroadcastRepository {
  final ApiClient _api;

  BroadcastRepository(this._api);

  Future<void> sendBroadcast({
    required String groupId, 
    required String title, 
    required String message
  }) async {
    try {
      // POST request to your backend
      await _api.post(
        '/groups/$groupId/broadcast', 
        data: {
          'title': title,
          'message': message,
          'priority': 'high', // Optional: customize based on urgency
        },
      );
    } on DioException catch (e) {
      // Clean error handling for UI display
      throw "Failed to send broadcast: ${e.response?.data['error'] ?? e.message}";
    }
  }
}