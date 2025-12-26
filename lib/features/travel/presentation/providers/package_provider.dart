import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:umrah_app/features/auth/presentation/providers/auth_provider.dart';
import '../../data/package_repository.dart';

// 1. Repository
final packageRepositoryProvider = Provider<PackageRepository>((ref) {
  return PackageRepository(ref.watch(apiClientProvider));
});

// 2. Data Provider (Defaults to UMRAH_PLUS for demo)
final packageListProvider = FutureProvider.autoDispose.family<List<TravelPackage>, String>((ref, category) async {
  final repo = ref.watch(packageRepositoryProvider);
  return repo.getPackages(category: category);
});