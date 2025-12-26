import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:umrah_app/features/auth/presentation/providers/auth_provider.dart';
import '../../data/itinerary_repository.dart';

// 1. Repository Provider
final itineraryRepositoryProvider = Provider<ItineraryRepository>((ref) {
  return ItineraryRepository(ref.watch(apiClientProvider));
});

// 2. Data Provider
final rundownProvider = FutureProvider.autoDispose<List<ItineraryItem>>((ref) async {
  final repo = ref.watch(itineraryRepositoryProvider);
  final groupId = ref.watch(authControllerProvider).groupId;

  if (groupId == null) return [];
  
  return repo.getRundown(groupId);
});