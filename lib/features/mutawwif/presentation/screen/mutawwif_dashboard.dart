import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 1. Auth Imports
import 'package:umrah_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:umrah_app/features/auth/presentation/screen/login_screen.dart'; 
// 2. Mutawwif Feature Imports
import 'package:umrah_app/features/mutawwif/presentation/screen/scan_qr_screen.dart';
import 'package:umrah_app/features/mutawwif/presentation/screen/tracking_screen.dart';
import 'package:umrah_app/features/mutawwif/presentation/screen/my_group_screen.dart';
import 'package:umrah_app/features/mutawwif/presentation/screen/broadcast_screen.dart';
import 'package:umrah_app/features/mutawwif/presentation/screen/attendance_screen.dart';

class MutawwifDashboard extends ConsumerWidget {
  const MutawwifDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mutawwif Panel", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 30),
            
            // 1. SCAN BUTTON
            SizedBox(
              height: 120,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ScanQrScreen()),
                  );
                },
                icon: const Icon(Icons.qr_code_scanner, size: 40, color: Colors.white),
                label: const Text(
                  "Scan Jamaah ID", 
                  style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 2. MENU GRID
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  // [FIX] Wired up My Group Screen
                  _menuCard(
                    Icons.group, 
                    "My Group", 
                    Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MyGroupScreen()),
                      );
                    }
                  ),  
                  _menuCard(
                    Icons.list_alt, 
                    "Attendance", 
                    Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AttendanceScreen()),
                      );
                    }
                  ),
                  _menuCard(
                    Icons.notifications, 
                    "Broadcast", 
                    Colors.red,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BroadcastScreen()),
                      );
                    },
                  ),      
                  // Track Group Button
                  _menuCard(
                    Icons.map, 
                    "Track Group", 
                    Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TrackingScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.teal.shade100),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.teal,
            child: Icon(Icons.person, color: Colors.white, size: 30),
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Ustadz Ahmad", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("Group: Kloter 14-B", style: TextStyle(color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }

  Widget _menuCard(IconData icon, String label, Color color, {VoidCallback? onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}