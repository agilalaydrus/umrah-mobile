import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:umrah_app/features/auth/presentation/providers/auth_provider.dart';
import '../providers/broadcast_provider.dart';

class BroadcastScreen extends ConsumerStatefulWidget {
  const BroadcastScreen({super.key});

  @override
  ConsumerState<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends ConsumerState<BroadcastScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendBroadcast() async {
    // 1. Validate Form
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    // 2. Get Group ID dynamically from Auth State
    final groupId = ref.read(authControllerProvider).groupId;

    if (groupId == null) {
      _showSnack("Error: No Group ID found. Are you logged in?", Colors.red);
      setState(() => _isLoading = false);
      return;
    }

    // 3. Send Request
    try {
      final repo = ref.read(broadcastRepositoryProvider);
      await repo.sendBroadcast(
        groupId: groupId,
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
      );

      if (mounted) {
        _showSnack("Announcement sent successfully! 🚀", Colors.green);
        Navigator.pop(context); // Go back to dashboard on success
      }
    } catch (e) {
      if (mounted) _showSnack("Failed: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Send Announcement"), backgroundColor: Colors.teal),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.campaign, size: 80, color: Colors.teal),
              const SizedBox(height: 20),
              const Text(
                "Notify your entire group instantly.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Title Input
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  hintText: "e.g., Bus Departure",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) => v!.isEmpty ? "Title is required" : null,
              ),
              const SizedBox(height: 20),

              // Message Input
              TextFormField(
                controller: _messageController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Message",
                  hintText: "e.g., Please gather at the lobby in 10 mins.",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (v) => v!.isEmpty ? "Message is required" : null,
              ),
              const SizedBox(height: 30),

              // Send Button
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _sendBroadcast,
                  icon: _isLoading 
                      ? const SizedBox.shrink() 
                      : const Icon(Icons.send, color: Colors.white),
                  label: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Send Notification", style: TextStyle(fontSize: 16, color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}