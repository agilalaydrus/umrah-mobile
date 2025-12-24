import 'package:dio/dio.dart';
import 'package:umrah_app/core/network/api_client.dart';

class AttendanceRecord {
  final String userId;
  final String name;
  final bool isPresent;
  final String? checkInTime;

  AttendanceRecord({
    required this.userId,
    required this.name,
    required this.isPresent,
    this.checkInTime,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      userId: json['user_id'] ?? '',
      name: json['name'] ?? 'Jamaah',
      isPresent: json['is_present'] ?? false,
      checkInTime: json['check_in_time'],
    );
  }
}

class AttendanceRepository {
  final ApiClient _api;

  AttendanceRepository(this._api);

  // Get today's attendance status
  Future<List<AttendanceRecord>> getAttendanceList(String groupId) async {
    try {
      final response = await _api.get('/groups/$groupId/attendance/today');
      return (response.data as List)
          .map((e) => AttendanceRecord.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw "Failed to load attendance: ${e.message}";
    }
  }

  // Mark a user as Present
  Future<void> markPresent(String userId, String groupId) async {
    try {
      await _api.post('/attendance', data: {
        'user_id': userId,
        'group_id': groupId,
        'status': 'PRESENT',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } on DioException catch (e) {
      throw "Failed to mark attendance: ${e.message}";
    }
  }
}