import 
'../domain/home_dashboard_data.dart';

class HomeRepository {
  // In the future, you will inject ApiClient here
  
  Future<HomeDashboardData> fetchDashboardData() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    return HomeDashboardData(
      pilgrimName: "Fulan bin Fulan",
      flightNumber: "GA-980",
      terminal: "Terminal 3",
      departureTime: DateTime.now().add(const Duration(days: 3, hours: 12)),
      currentStep: "Manasik Preparation",
    );
  }
}