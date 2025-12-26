import 'package:dio/dio.dart';
import 'package:umrah_app/core/network/api_client.dart';

class TravelPackage {
  final String id;
  final String name;
  final String description;
  final String category; // UMRAH_VIP, UMRAH_REGULAR
  final String hotelMakkah;
  final int ratingMakkah;
  final String airline;
  final double priceQuad; // Price for 4 people/room
  final double priceDouble; // Price for 2 people/room
  final DateTime departureDate;
  final int durationDays;
  final int quota;

  TravelPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.hotelMakkah,
    required this.ratingMakkah,
    required this.airline,
    required this.priceQuad,
    required this.priceDouble,
    required this.departureDate,
    required this.durationDays,
    required this.quota,
  });

  factory TravelPackage.fromJson(Map<String, dynamic> json) {
    return TravelPackage(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Package',
      description: json['description'] ?? '',
      category: json['category'] ?? 'UMRAH',
      hotelMakkah: json['hotel_makkah'] ?? 'TBA',
      ratingMakkah: json['rating_makkah'] ?? 3,
      airline: json['airline_name'] ?? 'TBA',
      priceQuad: (json['price_quad'] as num).toDouble(),
      priceDouble: (json['price_double'] as num).toDouble(),
      departureDate: DateTime.tryParse(json['departure_date'] ?? '') ?? DateTime.now(),
      durationDays: json['duration_days'] ?? 9,
      quota: json['quota'] ?? 0,
    );
  }
}

class PackageRepository {
  final ApiClient _api;

  PackageRepository(this._api);

  // 1. Get Packages (Filterable by category)
  Future<List<TravelPackage>> getPackages({String category = 'UMRAH_PLUS'}) async {
    try {
      final response = await _api.get('/packages?category=$category');
      return (response.data as List).map((e) => TravelPackage.fromJson(e)).toList();
    } on DioException catch (e) {
      throw "Failed to load packages: ${e.message}";
    }
  }

  // 2. Book Package
  Future<void> bookPackage({
    required String packageId,
    required String roomType, // DOUBLE, TRIPLE, QUAD
    required int paxCount,
  }) async {
    try {
      await _api.post('/bookings', data: {
        'package_id': packageId,
        'room_type': roomType,
        'pax_count': paxCount,
      });
    } on DioException catch (e) {
      throw "Booking Failed: ${e.response?.data['error'] ?? e.message}";
    }
  }
}