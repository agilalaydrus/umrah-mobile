import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:umrah_app/features/auth/presentation/providers/auth_provider.dart';
import '../providers/chat_provider.dart';
// [FIX] Import the ChatMessage model so we can use it as a type
import '../../data/chat_repository.dart'; 

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    // Start the auto-refresh timer
    ref.read(chatTimerProvider);
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final groupId = ref.read(authControllerProvider).groupId;
    if (groupId == null) return;

    setState(() => _sending = true);
    _msgController.clear(); 

    try {
      await ref.read(chatRepositoryProvider).sendMessage(groupId, text);
      ref.invalidate(chatMessagesProvider); 
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatAsync = ref.watch(chatMessagesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2), 
      appBar: AppBar(
        title: const Text("Group Discussion"),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          // 1. Message List
          Expanded(
            child: chatAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text("Error: $err")),
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(child: Text("No messages yet. Start chatting!"));
                }
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, 
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[messages.length - 1 - index];
                    return _buildBubble(msg);
                  },
                );
              },
            ),
          ),

          // 2. Input Area
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: IconButton(
                    icon: _sending 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sending ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // [FIX] Added explicit type 'ChatMessage' to the argument 'msg'
  Widget _buildBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: msg.isMe ? const Color(0xFFDCF8C6) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: msg.isMe ? const Radius.circular(12) : Radius.zero,
            bottomRight: msg.isMe ? Radius.zero : const Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              // [FIX] Replaced deprecated .withOpacity() with .withValues(alpha: ...)
              color: Colors.black.withValues(alpha: 0.05), 
              blurRadius: 2, 
              offset: const Offset(0, 1)
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!msg.isMe)
              Text(
                msg.senderName,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal.shade700),
              ),
            const SizedBox(height: 2),
            Text(msg.content, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 4),
            Text(
              "${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}",
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }
}