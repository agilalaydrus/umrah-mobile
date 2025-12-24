import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:umrah_app/features/auth/presentation/providers/auth_provider.dart';
import '../../data/group_repository.dart';

// 1. Repository Provider
final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return GroupRepository(ref.watch(apiClientProvider));
});

// 2. Data Provider (Fetches the list using Real ID)
final groupMembersProvider = FutureProvider.autoDispose<List<GroupMember>>((ref) async {
  final repo = ref.watch(groupRepositoryProvider);
  
  // [FIX] Watch the Auth State to get the dynamic ID
  final authState = ref.watch(authControllerProvider);
  final groupId = authState.groupId;

  // Safety Check: handle cases where ID is missing (e.g., admin or not assigned)
  if (groupId == null || groupId.isEmpty) {
    // Return empty list or throw error depending on desired UX
    return []; 
  }
  
  return repo.getGroupMembers(groupId);
});