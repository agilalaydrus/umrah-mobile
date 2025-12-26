import 'package:dio/dio.dart';
import 'package:umrah_app/core/network/api_client.dart';

class ItineraryItem {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime startTime;
  final DateTime endTime;

  ItineraryItem({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startTime,
    required this.endTime,
  });

  factory ItineraryItem.fromJson(Map<String, dynamic> json) {
    return ItineraryItem(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Activity',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      startTime: DateTime.tryParse(json['start_time'] ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(json['end_time'] ?? '') ?? DateTime.now(),
    );
  }
}

class ItineraryRepository {
  final ApiClient _api;

  ItineraryRepository(this._api);

  Future<List<ItineraryItem>> getRundown(String groupId) async {
    try {
      final response = await _api.get('/groups/$groupId/rundown');
      return (response.data as List)
          .map((e) => ItineraryItem.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw "Failed to load rundown: ${e.message}";
    }
  }
}