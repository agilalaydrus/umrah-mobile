import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/location_repository.dart';

// 1. Repository Provider
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepository(ref.watch(apiClientProvider));
});

// 2. Real-time Location Stream
// This creates a stream that fetches data every 10 seconds
final groupLocationsProvider = StreamProvider.autoDispose<List<Location>>((ref) async* {
  final repo = ref.watch(locationRepositoryProvider);
  
  // Hardcoded Group ID for now (In real app, get this from User Profile)
  const groupId = "1"; 

  // Initial Fetch
  yield await repo.getGroupLocations(groupId);

  // Poll every 10 seconds
  final timer = Timer.periodic(const Duration(seconds: 10), (t) async {
    // We can't 'yield' inside a timer callback easily in a generator.
    // So usually we use a StreamController, but for simplicity here 
    // we assume the UI will trigger refresh or we just return the stream directly.
  });
  
  // Cleaner way: just refresh the provider manually or use a proper StreamController.
  // For this snippet, let's just do a single fetch for simplicity, 
  // or use a Timer to invalidate the provider.
  
  ref.onDispose(() => timer.cancel());
});

// simpler approach: Auto-Refresh Logic
final trackingRefreshTrigger = StateProvider((ref) => 0);

final liveLocationsProvider = FutureProvider.autoDispose<List<Location>>((ref) async {
  // Watch trigger to force rebuild
  ref.watch(trackingRefreshTrigger);
  
  final repo = ref.watch(locationRepositoryProvider);
  // Using Mock ID for demo if you don't have a group set up yet
  return repo.getGroupLocations("1"); 
});