class HomeDashboardData {
  final String pilgrimName;
  final String flightNumber;
  final String terminal;
  final DateTime departureTime;
  final String currentStep; // e.g., "Manasik Preparation"

  HomeDashboardData({
    required this.pilgrimName,
    required this.flightNumber,
    required this.terminal,
    required this.departureTime,
    required this.currentStep,
  });

  // Helper to calculate "3 Days left"
  String get timeUntilDeparture {
    final diff = departureTime.difference(DateTime.now());
    if (diff.isNegative) return "Departed";
    return "${diff.inDays} Days, ${diff.inHours % 24} Hours";
  }
}