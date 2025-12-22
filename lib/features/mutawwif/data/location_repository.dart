import 'package:dio/dio.dart';
import 'package:umrah_app/core/network/api_client.dart';

class Location {
  final String userId;
  final String name;
  final double lat;
  final double lng;
  final DateTime lastUpdated;

  Location({
    required this.userId,
    required this.name,
    required this.lat,
    required this.lng,
    required this.lastUpdated,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      userId: json['user_id'] ?? 'unknown',
      name: json['name'] ?? 'Jamaah',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['updated_at']),
    );
  }
}

class LocationRepository {
  final ApiClient _api;

  LocationRepository(this._api);

  Future<List<Location>> getGroupLocations(String groupId) async {
    try {
      final response = await _api.get('/groups/$groupId/locations');
      return (response.data as List)
          .map((e) => Location.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw "Failed to fetch locations: ${e.message}";
    }
  }
}