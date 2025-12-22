import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/data/home_repository.dart';
import '../../home/domain/home_dashboard_data.dart';

// 1. Provider for the Repository
final homeRepositoryProvider = Provider((ref) => HomeRepository());

// 2. Provider for the Data (FutureProvider handles Loading/Error auto-magically)
final homeDataProvider = FutureProvider<HomeDashboardData>((ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.fetchDashboardData();
});