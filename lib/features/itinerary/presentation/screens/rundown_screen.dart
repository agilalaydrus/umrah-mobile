import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/itinerary_provider.dart';
import '../../data/itinerary_repository.dart';

class RundownScreen extends ConsumerWidget {
  const RundownScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rundownAsync = ref.watch(rundownProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Itinerary Schedule"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(rundownProvider),
          )
        ],
      ),
      body: rundownAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (items) {
          if (items.isEmpty) {
             return const Center(child: Text("No activities scheduled."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildTimelineItem(item, index, items.length);
            },
          );
        },
      ),
    );
  }

  Widget _buildTimelineItem(ItineraryItem item, int index, int total) {
    final isLast = index == total - 1;

    // formatting helper (Hour:Minute)
    String formatTime(DateTime dt) {
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Time Column
          SizedBox(
            width: 60,
            child: Column(
              children: [
                Text(
                  formatTime(item.startTime), 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                ),
                Text(
                  "Day ${item.startTime.day}", 
                  style: const TextStyle(fontSize: 12, color: Colors.grey)
                ),
              ],
            ),
          ),
          
          // 2. Vertical Line & Dot
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Colors.teal,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // 3. Content Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade200, blurRadius: 6, offset: const Offset(0, 3))
                ],
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.location, 
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.description, 
                    style: const TextStyle(fontSize: 14, color: Colors.black87)
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}