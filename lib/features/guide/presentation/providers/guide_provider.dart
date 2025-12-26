import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:umrah_app/features/auth/presentation/providers/auth_provider.dart';
import '../../data/guide_repository.dart';

// 1. Repository Provider
final guideRepositoryProvider = Provider<GuideRepository>((ref) {
  return GuideRepository(ref.watch(apiClientProvider));
});

// 2. State for the selected Category Tab (Defaults to 'UMRAH')
final selectedCategoryProvider = StateProvider<String>((ref) => 'UMRAH');

// 3. Data Provider (Fetches data based on the selected category)
final guideListProvider = FutureProvider.autoDispose<List<GuideContent>>((ref) async {
  final repo = ref.watch(guideRepositoryProvider);
  final category = ref.watch(selectedCategoryProvider);
  
  return repo.getGuides(category);
});