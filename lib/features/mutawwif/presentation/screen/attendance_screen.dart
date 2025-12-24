import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/attendance_provider.dart';
import '../../data/attendance_repository.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(attendanceListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Attendance"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(attendanceListProvider),
          )
        ],
      ),
      body: attendanceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (records) {
          final presentCount = records.where((r) => r.isPresent).length;
          final total = records.length;

          return Column(
            children: [
              // 1. Summary Header
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.teal.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statusBadge("Total", "$total", Colors.blue),
                    _statusBadge("Present", "$presentCount", Colors.green),
                    _statusBadge("Missing", "${total - presentCount}", Colors.red),
                  ],
                ),
              ),

              // 2. The Checklist
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: records.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return _buildAttendanceRow(context, ref, record);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statusBadge(String label, String count, Color color) {
    return Column(
      children: [
        Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildAttendanceRow(BuildContext context, WidgetRef ref, AttendanceRecord record) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: record.isPresent ? Colors.green : Colors.grey.shade300,
        child: Icon(
          record.isPresent ? Icons.check : Icons.person,
          color: Colors.white,
        ),
      ),
      title: Text(record.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        record.isPresent ? "Checked in at ${record.checkInTime ?? 'now'}" : "Not present yet",
        style: TextStyle(color: record.isPresent ? Colors.green : Colors.red),
      ),
      trailing: record.isPresent
          ? null // Hide button if already present
          : ElevatedButton(
              onPressed: () async {
                try {
                  // Call the mark function
                  await ref.read(markAttendanceProvider)(record.userId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${record.name} marked Present")),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed: $e"), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Check In", style: TextStyle(color: Colors.white)),
            ),
    );
  }
}