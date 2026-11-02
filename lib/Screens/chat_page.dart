
import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../widgets/chat_bubble.dart';
import '../services/ai_chat_service.dart';
import '../services/chat_storage_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatStorageService _storageService = ChatStorageService();

  final AiChatService _chatService = AiChatService();

  final TextEditingController _controller = TextEditingController();

  final List<ChatMessage> _messages = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  // Load saved messages
  Future<void> _loadChatHistory() async {
    final savedMessages = await _storageService.loadMessages();

    if (!mounted) return;

    setState(() {
      _messages.addAll(savedMessages);
    });
  }

  // Clear chat
  Future<void> _clearChat() async {
    if (_isLoading) return;

    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear Chat?'),
          content: const Text(
            'Are you sure you want to delete this conversation?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (shouldClear != true) return;

    await _storageService.clearMessages();

    if (!mounted) return;

    setState(() {
      _messages.clear();
    });
  }

  // Send message
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();

    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
        ),
      );

      _isLoading = true;
    });

    _controller.clear();

    await _storageService.saveMessages(_messages);

    String reply;

    try {
  reply = await _chatService.getReply(_messages);
} catch (e) {
  debugPrint('Gemini error: $e');
  reply = 'Error: $e';
}

    if (!mounted) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: reply,
          isUser: false,
        ),
      );

      _isLoading = false;
    });

    await _storageService.saveMessages(_messages);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat Assistant'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _clearChat,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear chat',
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text(
                      'Hello! Ask me anything.',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return ChatBubble(
                        message: _messages[index],
                      );
                    },
                  ),
          ),

          if (_isLoading)
  const Padding(
    padding: EdgeInsets.all(12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
        SizedBox(width: 10),
        Text('Assistant is typing...'),
      ],
    ),
  ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  icon: const Icon(Icons.send),
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
