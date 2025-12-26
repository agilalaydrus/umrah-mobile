import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:umrah_app/features/auth/presentation/providers/auth_provider.dart';
import '../../data/chat_repository.dart';

// Repository
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(apiClientProvider));
});

// Auto-Refresh Logic (Poll every 3 seconds for new messages)
final chatRefreshTrigger = StateProvider((ref) => 0);

// Data Provider
final chatMessagesProvider = FutureProvider.autoDispose<List<ChatMessage>>((ref) async {
  // Trigger rebuild when timer ticks
  ref.watch(chatRefreshTrigger);
  
  final repo = ref.watch(chatRepositoryProvider);
  final auth = ref.watch(authControllerProvider);
  
  if (auth.groupId == null || auth.phoneNumber == null) return [];

  return repo.getMessages(auth.groupId!, auth.phoneNumber!);
});

// Timer to force refresh
final chatTimerProvider = Provider.autoDispose((ref) {
  final timer = Timer.periodic(const Duration(seconds: 3), (t) {
    ref.read(chatRefreshTrigger.notifier).state++;
  });
  ref.onDispose(() => timer.cancel());
});