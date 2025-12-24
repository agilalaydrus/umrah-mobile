import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:umrah_app/features/auth/presentation/providers/auth_provider.dart';
import '../../data/attendance_repository.dart';

// 1. Repository Provider
final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(ref.watch(apiClientProvider));
});

// 2. Data Provider (The List)
final attendanceListProvider = FutureProvider.autoDispose<List<AttendanceRecord>>((ref) async {
  final repo = ref.watch(attendanceRepositoryProvider);
  // Dynamically get the Group ID
  final groupId = ref.watch(authControllerProvider).groupId;

  if (groupId == null) return [];
  return repo.getAttendanceList(groupId);
});

// 3. Action Logic (Mark Present)
final markAttendanceProvider = Provider((ref) {
  return (String userId) async {
    final repo = ref.read(attendanceRepositoryProvider);
    final groupId = ref.read(authControllerProvider).groupId;
    
    if (groupId != null) {
      await repo.markPresent(userId, groupId);
      // Refresh the list immediately to show the green checkmark
      ref.invalidate(attendanceListProvider);
    }
  };
});