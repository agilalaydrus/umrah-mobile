import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import the domain model
import '../domain/home_dashboard_data.dart';
// Import the Home Provider
import 'home_provider.dart';
// Import the Auth Provider (to get User ID)
import '../../auth/presentation/providers/auth_provider.dart';
// Import the QR Widget
import 'widgets/qr_id_modal.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the Home Data (Departure time, flight, etc.)
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
              // 1. Status Card
              _buildStatusCard(data),

              const SizedBox(height: 20),
              
              // 2. Quick Actions (Now functional!)
              _buildQuickActions(context, ref),
              
              const SizedBox(height: 20),
              
              // 3. Current Step
              _buildCurrentStep(data.currentStep),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // 1. My ID (Opens QR Modal)
        _actionButton(
          icon: Icons.qr_code, 
          label: "My ID", 
          onTap: () {
            // Read User ID from Auth State
            final userId = ref.read(authControllerProvider).userId;
            
            if (userId != null) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true, // Allows modal to be taller if needed
                backgroundColor: Colors.transparent,
                builder: (context) => QrIdModal(userId: userId),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Error: User ID missing. Please login again.")),
              );
            }
          }
        ),

        // 2. Placeholders for other features
        _actionButton(icon: Icons.menu_book, label: "Doa", onTap: () {}),
        _actionButton(icon: Icons.map, label: "Map", onTap: () {}),
        _actionButton(icon: Icons.support_agent, label: "Help", onTap: () {}),
      ],
    );
  }

  // Helper for consistent buttons
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

  Widget _buildCurrentStep(String step) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.location_on, color: Colors.orange),
        title: const Text("Next Activity", style: TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(step, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}