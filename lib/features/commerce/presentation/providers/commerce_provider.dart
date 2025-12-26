import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:umrah_app/features/auth/presentation/providers/auth_provider.dart';
import '../../data/commerce_repository.dart';

// 1. Repository
final commerceRepositoryProvider = Provider<CommerceRepository>((ref) {
  return CommerceRepository(ref.watch(apiClientProvider));
});

// 2. Data Provider (Catalog)
final productListProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final repo = ref.watch(commerceRepositoryProvider);
  return repo.getProducts();
});