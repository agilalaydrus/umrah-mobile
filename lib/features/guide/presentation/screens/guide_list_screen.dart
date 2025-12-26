import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/guide_provider.dart';
import '../../data/guide_repository.dart';
import '../screens/guide_detail_screen.dart'; 

class GuideListScreen extends ConsumerWidget {
  const GuideListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guidesAsync = ref.watch(guideListProvider);
    final selectedCat = ref.watch(selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manasik & Doa"),
        backgroundColor: Colors.teal,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.white,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _FilterTab(ref, "UMRAH", "Umrah Guide", selectedCat == "UMRAH"),
                _FilterTab(ref, "DUA", "Daily Duas", selectedCat == "DUA"),
                _FilterTab(ref, "ZIARAH", "Ziarah", selectedCat == "ZIARAH"),
              ],
            ),
          ),
        ),
      ),
      body: guidesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (guides) {
          if (guides.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("No content found for this category.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: guides.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final guide = guides[index];
              return _buildGuideCard(context, guide, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildGuideCard(BuildContext context, GuideContent guide, int index) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.teal.shade50,
          radius: 20,
          child: Text(
            "${index + 1}", 
            style: TextStyle(color: Colors.teal.shade800, fontWeight: FontWeight.bold)
          ),
        ),
        title: Text(
          guide.title, 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
        ),
        subtitle: Text(
          guide.translation, 
          maxLines: 1, 
          overflow: TextOverflow.ellipsis
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => GuideDetailScreen(guide: guide)),
          );
        },
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final WidgetRef ref;
  final String categoryKey;
  final String label;
  final bool isSelected;

  const _FilterTab(this.ref, this.categoryKey, this.label, this.isSelected);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () => ref.read(selectedCategoryProvider.notifier).state = categoryKey,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: isSelected 
                ? const Border(bottom: BorderSide(color: Colors.teal, width: 3)) 
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.teal : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}