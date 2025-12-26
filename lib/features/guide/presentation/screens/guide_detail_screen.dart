import 'package:flutter/material.dart';
import '../../data/guide_repository.dart';

class GuideDetailScreen extends StatelessWidget {
  final GuideContent guide;

  const GuideDetailScreen({super.key, required this.guide});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(guide.title),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Audio Player Placeholder (Optional)
            if (guide.audioUrl != null && guide.audioUrl!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.shade100),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: const Icon(Icons.play_arrow, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "Play Audio Guide",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ],
                ),
              ),

            // 2. Arabic Text Area
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFDFD), // Off-white paper look
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade100,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Text(
                guide.arabicText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontFamily: 'Amiri', // Ensure you have a font or use system default
                  height: 2.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            
            const SizedBox(height: 24),

            // 3. Latin Transliteration
            const Text(
              "Transliteration",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              guide.latinText,
              style: const TextStyle(
                fontSize: 16, 
                color: Colors.teal, 
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
            
            const Divider(height: 40),

            // 4. Translation
            const Text(
              "Meaning (Arti)",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              guide.translation,
              style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}