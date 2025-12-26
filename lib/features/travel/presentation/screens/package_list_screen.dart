import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Make sure you ran 'flutter pub add intl'
import '../providers/package_provider.dart';
import '../../data/package_repository.dart';
import 'package_detail_screen.dart';

class PackageListScreen extends ConsumerWidget {
  const PackageListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageAsync = ref.watch(packageListProvider("UMRAH_PLUS"));

    return Scaffold(
      appBar: AppBar(title: const Text("Travel Packages"), backgroundColor: Colors.teal),
      body: packageAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (packages) {
          if (packages.isEmpty) return const Center(child: Text("No packages available."));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: packages.length,
            itemBuilder: (context, index) {
              return _buildPackageCard(context, packages[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildPackageCard(BuildContext context, TravelPackage pkg) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    // [FIX] Removed unused 'dateFmt' variable

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
           Navigator.push(
             context, 
             MaterialPageRoute(builder: (_) => PackageDetailScreen(pkg: pkg))
           );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.teal.shade800,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                image: const DecorationImage(
                  image: NetworkImage("https://placeholder.com/mechanics"), 
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken)
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4)),
                    child: Text("${pkg.durationDays} Days", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const SizedBox(height: 8),
                  Text(pkg.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _iconText(Icons.flight, pkg.airline),
                      _iconText(Icons.hotel, pkg.hotelMakkah),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Start from", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(currency.format(pkg.priceQuad), style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                           Navigator.push(
                             context, 
                             MaterialPageRoute(builder: (_) => PackageDetailScreen(pkg: pkg))
                           );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                        child: const Text("View Details", style: TextStyle(color: Colors.white)),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _iconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}