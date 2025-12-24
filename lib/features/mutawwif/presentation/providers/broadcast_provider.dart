import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:umrah_app/features/auth/presentation/providers/auth_provider.dart';
import '../../data/broadcast_repository.dart';

// The Repository Provider
final broadcastRepositoryProvider = Provider<BroadcastRepository>((ref) {
  // Use the shared API client from Auth
  return BroadcastRepository(ref.watch(apiClientProvider));
});