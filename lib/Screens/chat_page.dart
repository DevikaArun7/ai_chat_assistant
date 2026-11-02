
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
  final TextEditingController _controller = TextEditingController();

  final AiChatService _chatService = AiChatService();
  final ChatStorageService _storageService = ChatStorageService();

  final List<ChatMessage> _messages = [];

  bool _isLoading = false;

  final Color primaryColor = const Color(0xFF6750A4);
  final Color backgroundColor = const Color(0xFFF7F4FC);

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  // Load previous chat messages
  Future<void> _loadChatHistory() async {
    final savedMessages = await _storageService.loadMessages();

    if (!mounted) return;

    setState(() {
      _messages.addAll(savedMessages);
    });
  }

  // Save chat messages
  Future<void> _saveChatHistory() async {
    await _storageService.saveMessages(_messages);
  }

  // Send message to Gemini
  Future<void> _sendMessage({String? text}) async {
    final messageText = (text ?? _controller.text).trim();

    if (messageText.isEmpty || _isLoading) return;

    _controller.clear();

    final userMessage = ChatMessage(
      text: messageText,
      isUser: true,
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    await _saveChatHistory();

    try {
      final reply = await _chatService.getReply(_messages);

      if (!mounted) return;

      setState(() {
        _messages.add(
          ChatMessage(
            text: reply,
            isUser: false,
          ),
        );
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _messages.add(
          ChatMessage(
            text: 'Something went wrong. Please try again.\n$error',
            isUser: false,
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        await _saveChatHistory();
      }
    }
  }

  // Clear chat history
  Future<void> _clearChat() async {
    if (_isLoading) return;

    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear chat?'),
          content: const Text(
            'Are you sure you want to delete all chat messages?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Clear',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (shouldClear == true) {
      await _storageService.clearMessages();

      if (!mounted) return;

      setState(() {
        _messages.clear();
      });
    }
  }

  // Suggested message buttons
  Widget _buildSuggestion(String text) {
    return InkWell(
      onTap: _isLoading
          ? null
          : () => _sendMessage(text: text),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE8E0F2),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF443A54),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Color(0xFF6750A4),
            ),
          ],
        ),
      ),
    );
  }

  // Welcome screen
  Widget _buildWelcomeScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 75,
              width: 75,
              decoration: BoxDecoration(
                color: const Color(0xFFE9DDFB),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 38,
                color: Color(0xFF6750A4),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Hello! How can I help you?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color(0xFF292333),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Ask me anything. I am here to help you.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 30),

            _buildSuggestion('Explain Flutter in simple words'),
            const SizedBox(height: 12),

            _buildSuggestion('Give me some project ideas'),
            const SizedBox(height: 12),

            _buildSuggestion('How can I improve my coding skills?'),
          ],
        ),
      ),
    );
  }

  // Typing indicator
  Widget _buildTypingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: Color(0xFFE9DDFB),
            child: Icon(
              Icons.auto_awesome,
              size: 19,
              color: Color(0xFF6750A4),
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Assistant is typing...',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 13,
            ),
          ),
          SizedBox(width: 10),
          SizedBox(
            height: 15,
            width: 15,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF6750A4),
            ),
          ),
        ],
      ),
    );
  }

  // Message input area
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFEDE8F3),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: !_isLoading,
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Ask me anything...',
                  hintStyle: const TextStyle(
                    color: Colors.black45,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF7F4FC),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(
                      color: Color(0xFF6750A4),
                    ),
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),

            const SizedBox(width: 10),

            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: _isLoading
                    ? Colors.grey
                    : primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _isLoading
                    ? null
                    : () => _sendMessage(),
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE9DDFB),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Color(0xFF6750A4),
              ),
            ),

            const SizedBox(width: 12),

            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF292333),
                  ),
                ),
                Text(
                  'Powered by Gemini',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),

        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                _clearChat();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Clear chat'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildWelcomeScreen()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return _buildTypingIndicator();
                      }

                      return ChatBubble(
                        message: _messages[index],
                      );
                    },
                  ),
          ),

          _buildMessageInput(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
