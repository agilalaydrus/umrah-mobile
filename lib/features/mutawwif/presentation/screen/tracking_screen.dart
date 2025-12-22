import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

// [FIX] Absolute Imports to find the files we just created
import 'package:umrah_app/features/mutawwif/providers/tracking_providers.dart';
import 'package:umrah_app/features/mutawwif/data/location_repository.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  final MapController _mapController = MapController();
  Timer? _refreshTimer;

  // Default: Masjid Al Haram Coordinates
  final LatLng _center = const LatLng(21.4225, 39.8262); 

  @override
  void initState() {
    super.initState();
    // Auto-refresh data every 10 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      ref.invalidate(liveLocationsProvider);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Now this provider exists!
    final locationsAsync = ref.watch(liveLocationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Group Live Tracking"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(liveLocationsProvider),
          )
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _center,
          initialZoom: 15.0,
        ),
        children: [
          // 1. The Map Tile Layer (OpenStreetMap)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.umrah.app',
          ),

          // 2. The Markers (Jamaah)
          MarkerLayer(
            markers: locationsAsync.when(
              data: (locations) => locations.map((loc) => _buildMarker(loc)).toList(),
              loading: () => [], 
              error: (_, _) => [], 
            ),
          ),
        ],
      ),
      // Floating Status Card
      bottomSheet: locationsAsync.when(
        data: (locations) => Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Text(
            "${locations.length} Jamaah Active",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
        loading: () => const LinearProgressIndicator(color: Colors.teal),
        error: (err, _) => Container(
          color: Colors.red.shade100,
          padding: const EdgeInsets.all(8),
          child: Text("Error: $err", textAlign: TextAlign.center),
        ),
      ),
    );
  }

  Marker _buildMarker(Location loc) {
    return Marker(
      point: LatLng(loc.lat, loc.lng),
      width: 80,
      height: 80,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black26)],
            ),
            child: const Icon(Icons.person, color: Colors.teal, size: 20),
          ),
          const SizedBox(height: 2),
          Text(
            loc.name,
            style: const TextStyle(
              fontSize: 10, 
              fontWeight: FontWeight.bold,
              color: Colors.black,
              backgroundColor: Colors.white70
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}