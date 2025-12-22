import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrIdModal extends StatelessWidget {
  final String userId;

  const QrIdModal({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 24),
          
          const Text("My Umrah ID", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
          const SizedBox(height: 8),
          const Text("Show this to your Mutawwif", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            // [FIX] Updated QR Code syntax
            child: QrImageView(
              data: userId,
              version: QrVersions.auto,
              size: 200.0,
              // 'foregroundColor' is deprecated. Use these instead:
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.black,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          Text("ID: $userId", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}