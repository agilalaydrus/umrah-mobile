import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/group_provider.dart';
import '../../data/group_repository.dart';

class MyGroupScreen extends ConsumerWidget {
  const MyGroupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(groupMembersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Group (Kloter 14-B)"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(groupMembersProvider),
          ),
        ],
      ),
      body: membersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        // ... inside build()
        data: (members) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: members.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final member = members[index];
            return _buildMemberCard(member, context);
          },
        ),
      ),
    );
  }

  Widget _buildMemberCard(GroupMember member, BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        // Avatar
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage(member.photoUrl),
          backgroundColor: Colors.teal.shade100,
        ),
        // Name & Phone
        title: Text(
          member.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(member.phoneNumber),
        
        // Status & Call Button
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Dot
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: member.status == "SAFE" ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                member.status,
                style: TextStyle(
                  color: member.status == "SAFE" ? Colors.green.shade800 : Colors.red.shade800,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Call Button
            IconButton(
              icon: const Icon(Icons.phone, color: Colors.teal),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Calling ${member.name}...")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}