import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/home_dashboard_data.dart';
import 'home_provider.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import 'widgets/qr_id_modal.dart';
// Feature Imports
import 'package:umrah_app/features/chat/presentation/screen/chat_screen.dart';
import 'package:umrah_app/features/guide/presentation/screens/guide_list_screen.dart';
import 'package:umrah_app/features/itinerary/presentation/screens/rundown_screen.dart';
import 'package:umrah_app/features/commerce/presentation/screens/catalog_screen.dart';
import 'package:umrah_app/features/travel/presentation/screens/package_list_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(homeDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("UmrahConnect"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(homeDataProvider);
            },
          )
        ],
      ),
      body: dashboardState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildStatusCard(data),
              const SizedBox(height: 20),
              
              // 2. Quick Actions
              _buildQuickActions(context, ref),
              
              const SizedBox(height: 20),
              
              // 3. Current Step
              _buildCurrentStep(context, data.currentStep),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(HomeDashboardData data) { 
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.teal,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.3), 
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Departure in", style: TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 5),
          Text(data.timeUntilDeparture, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Divider(color: Colors.white30),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Flight: ${data.flightNumber}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              Text(data.terminal, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
            ],
          )
        ],
      ),
    );
  }
  
  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    // We use a Wrap instead of Row to allow multiple lines of buttons
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: [
        // 1. My ID
        _actionButton(
          icon: Icons.qr_code, 
          label: "My ID", 
          onTap: () {
            final userId = ref.read(authControllerProvider).userId;
            if (userId != null) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => QrIdModal(userId: userId),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Error: User ID missing.")),
              );
            }
          }
        ),

        // 2. Chat
        _actionButton(
          icon: Icons.chat, 
          label: "Chat", 
          onTap: () {
             Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => const ChatScreen()),
             );
          }
        ),

        // 3. Manasik
        _actionButton(
          icon: Icons.menu_book, 
          label: "Manasik", 
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GuideListScreen()),
            );
          }
        ),

        // 4. Store (Roaming)
        _actionButton(
          icon: Icons.store, 
          label: "Store", 
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CatalogScreen()),
            );
          }
        ),

        // 5. Packages (New)
        _actionButton(
          icon: Icons.flight_takeoff, 
          label: "Packages", 
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PackageListScreen()),
            );
          }
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon, 
    required String label, 
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Keep it compact
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.teal.shade50,
              child: Icon(icon, color: Colors.teal),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context, String step) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RundownScreen()),
        );
      },
      child: Card(
        elevation: 2,
        child: ListTile(
          leading: const Icon(Icons.location_on, color: Colors.orange),
          title: const Text("Next Activity", style: TextStyle(fontSize: 12, color: Colors.grey)),
          subtitle: Text(step, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        ),
      ),
    );
  }
}