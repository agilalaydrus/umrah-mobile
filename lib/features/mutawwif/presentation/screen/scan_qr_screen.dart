import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  bool _isScanned = false; // Prevent multiple scans at once

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Jamaah ID"), backgroundColor: Colors.teal),
      body: MobileScanner(
        // 1. Handle the detected barcode
        onDetect: (capture) {
          if (_isScanned) return; // Ignore if already processing

          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              setState(() => _isScanned = true);
              _handleScanSuccess(barcode.rawValue!);
              break; 
            }
          }
        },
      ),
    );
  }

  void _handleScanSuccess(String userId) {
    // 2. Show Result (Later, this will fetch User Details from API)
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: 300,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            const Text("Jamaah Identified!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("User ID: $userId", style: const TextStyle(fontSize: 16, fontFamily: 'monospace')),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Reset scan state and close modal
                Navigator.pop(context); 
                setState(() => _isScanned = false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)
              ),
              child: const Text("Scan Next", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}