import 'package:dio/dio.dart';
import 'package:umrah_app/core/network/api_client.dart';

class ChatMessage {
  final String id;
  final String senderName;
  final String senderPhone;
  final String content;
  final DateTime timestamp;
  final bool isMe; // Helper to align bubbles

  ChatMessage({
    required this.id,
    required this.senderName,
    required this.senderPhone,
    required this.content,
    required this.timestamp,
    required this.isMe,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, String myPhone) {
    final senderPhone = json['sender_phone'] ?? '';
    return ChatMessage(
      id: json['id'] ?? '',
      senderName: json['sender_name'] ?? 'Unknown',
      senderPhone: senderPhone,
      content: json['content'] ?? '',
      timestamp: DateTime.parse(json['created_at']),
      isMe: senderPhone == myPhone,
    );
  }
}

class ChatRepository {
  final ApiClient _api;

  ChatRepository(this._api);

  // Get Chat History
  Future<List<ChatMessage>> getMessages(String groupId, String myPhone) async {
    try {
      final response = await _api.get('/groups/$groupId/chat');
      return (response.data as List)
          .map((e) => ChatMessage.fromJson(e, myPhone))
          .toList();
    } on DioException catch (e) {
      throw "Failed to load chat: ${e.message}";
    }
  }

  // Send Message
  Future<void> sendMessage(String groupId, String content) async {
    try {
      await _api.post('/groups/$groupId/chat', data: {
        'content': content,
      });
    } on DioException catch (e) {
      throw "Failed to send: ${e.message}";
    }
  }
}