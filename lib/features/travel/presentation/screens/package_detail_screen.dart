import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Ensure 'flutter pub add intl' is run
import '../../data/package_repository.dart';
import '../providers/package_provider.dart';

class PackageDetailScreen extends ConsumerStatefulWidget {
  final TravelPackage pkg;

  const PackageDetailScreen({super.key, required this.pkg});

  @override
  ConsumerState<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends ConsumerState<PackageDetailScreen> {
  String _selectedRoom = 'QUAD'; 
  int _paxCount = 1;
  bool _isBooking = false;

  Future<void> _bookNow() async {
    setState(() => _isBooking = true);
    try {
      await ref.read(packageRepositoryProvider).bookPackage(
        packageId: widget.pkg.id,
        roomType: _selectedRoom,
        paxCount: _paxCount,
      );
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Booking Success!"),
            content: const Text("Your seat has been reserved. Please contact admin for payment."),
            actions: [
              TextButton(onPressed: () {
                Navigator.pop(context); 
                Navigator.pop(context); 
              }, child: const Text("OK"))
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text("Package Details"), backgroundColor: Colors.teal),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.pkg.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(widget.pkg.description, style: const TextStyle(color: Colors.grey, height: 1.5)),
            const SizedBox(height: 20),
            
            // Configuration Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text("Select Options", style: TextStyle(fontWeight: FontWeight.bold)),
                    const Divider(),
                    
                    // [FIX] Replaced DropdownButtonFormField with standard DropdownButton to avoid deprecation warning
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedRoom,
                          items: const [
                            DropdownMenuItem(value: 'QUAD', child: Text("Quad (4 Pax/Room)")),
                            DropdownMenuItem(value: 'DOUBLE', child: Text("Double (2 Pax/Room)")),
                          ],
                          onChanged: (val) => setState(() => _selectedRoom = val!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Pax Counter
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Number of Pax:"),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _paxCount > 1 ? () => setState(() => _paxCount--) : null,
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text("$_paxCount", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            IconButton(
                              onPressed: () => setState(() => _paxCount++),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        )
                      ],
                    ),
                    const Divider(),

                    // Total Price Calculation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Estimate:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          currency.format(
                            (_selectedRoom == 'QUAD' ? widget.pkg.priceQuad : widget.pkg.priceDouble) * _paxCount
                          ),
                          style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isBooking ? null : _bookNow,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: _isBooking 
                ? const CircularProgressIndicator(color: Colors.white) 
                : const Text("Confirm Booking", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ),
      ),
    );
  }
}