import 'package:dio/dio.dart';
import 'package:umrah_app/core/network/api_client.dart';

class GroupMember {
  final String id;
  final String name;
  final String phoneNumber;
  final String status; // e.g., "SAFE", "LOST", "UNKNOWN"
  final String photoUrl;

  GroupMember({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.status,
    required this.photoUrl,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'] ?? '',
      name: json['full_name'] ?? 'Jamaah',
      phoneNumber: json['phone_number'] ?? '',
      status: json['status'] ?? 'SAFE',
      // Placeholder image if none provided
      photoUrl: json['photo_url'] ?? 'https://i.pravatar.cc/150?u=${json['id']}',
    );
  }
}

class GroupRepository {
  final ApiClient _api;

  GroupRepository(this._api);

  Future<List<GroupMember>> getGroupMembers(String groupId) async {
    try {
      final response = await _api.get('/groups/$groupId/members');
      return (response.data as List)
          .map((e) => GroupMember.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw "Failed to fetch members: ${e.message}";
    }
  }
}