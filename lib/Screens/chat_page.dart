import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../services/ai_chat_service.dart';
import '../services/chat_storage_service.dart';
import '../widgets/chat_bubble.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Create service objects.
  final ChatStorageService _storageService = ChatStorageService();
  final AiChatService _chatService = AiChatService();

  final List<ChatMessage> _messages = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  // Load previously saved messages.
  Future<void> _loadChatHistory() async {
    final savedMessages = await _storageService.loadMessages();

    if (!mounted) return;

    setState(() {
      _messages.addAll(savedMessages);
    });

    _scrollToBottom();
  }

  // Clear conversation.
  Future<void> _clearChat() async {
    await _storageService.clearMessages();

    if (!mounted) return;

    setState(() {
      _messages.clear();
    });
  }

  // Send message to Gemini.
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
    _scrollToBottom();

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

      await _storageService.saveMessages(_messages);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong: $e'),
          backgroundColor: const Color(0xFFDC4568),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        _scrollToBottom();
      }
    }
  }

  // Automatically scroll to latest message.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF100D20),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF17112D),
              Color(0xFF100D20),
              Color(0xFF090817),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),

              Expanded(
                child: _messages.isEmpty
                    ? _buildWelcomeScreen()
                    : _buildMessageList(),
              ),

              if (_isLoading) _buildTypingIndicator(),

              _buildMessageInput(),
            ],
          ),
        ),
      ),
    );
  }

  // App bar.
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      child: Row(
        children: [
          Container(
            height: 43,
            width: 43,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF9B5CFF),
                  Color(0xFF6735C9),
                ],
              ),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      color: Color(0xFF45D6A1),
                      size: 8,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Online • Ready to help',
                      style: TextStyle(
                        color: Color(0xFFAAA4BD),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: _clearChat,
            tooltip: 'Clear chat',
            icon: const Icon(
              Icons.delete_outline,
              color: Color(0xFFB9B2CC),
            ),
          ),
        ],
      ),
    );
  }

  // Welcome screen.
  Widget _buildWelcomeScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 95,
              width: 95,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF9B5CFF),
                    Color(0xFF5426B8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6)
                        .withValues(alpha: 0.3),
                    blurRadius: 35,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 43,
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Hello there! 👋',
              style: TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'I am your AI assistant.\nWhat would you like to explore today?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFAAA4BD),
                fontSize: 14,
                height: 1.7,
              ),
            ),

            const SizedBox(height: 30),

            _suggestionCard(
              Icons.code,
              'Explain a programming concept',
              'Explain Flutter widgets in simple words',
            ),

            _suggestionCard(
              Icons.lightbulb_outline,
              'Give me creative ideas',
              'Give me some creative app ideas',
            ),

            _suggestionCard(
              Icons.school_outlined,
              'Help me learn something',
              'Teach me something interesting today',
            ),
          ],
        ),
      ),
    );
  }

  // Suggestion cards.
  Widget _suggestionCard(
    IconData icon,
    String title,
    String prompt,
  ) {
    return GestureDetector(
      onTap: () {
        _controller.text = prompt;
        _sendMessage();
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 11),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF211B35),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.07),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFFB18AFF),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 13,
              color: Color(0xFFAAA4BD),
            ),
          ],
        ),
      ),
    );
  }

  // Chat messages.
  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 15,
      ),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return ChatBubble(
          message: _messages[index],
        );
      },
    );
  }

  // AI loading indicator.
  Widget _buildTypingIndicator() {
    return const Padding(
      padding: EdgeInsets.only(
        left: 20,
        bottom: 12,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Icon(
              Icons.auto_awesome,
              color: Color(0xFFB18AFF),
              size: 17,
            ),
            SizedBox(width: 9),
            Text(
              'AI is thinking...',
              style: TextStyle(
                color: Color(0xFFAAA4BD),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Message input area.
  Widget _buildMessageInput() {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 8, 15, 15),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF25213A),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: const Color(0xFF7251B5)
              .withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !_isLoading,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              minLines: 1,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Ask me anything...',
                hintStyle: TextStyle(
                  color: Color(0xFF8E879F),
                  fontSize: 13,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),

          const SizedBox(width: 8),

          GestureDetector(
            onTap: _isLoading ? null : _sendMessage,
            child: Container(
              height: 43,
              width: 43,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF9B5CFF),
                    Color(0xFF6735C9),
                  ],
                ),
              ),
              child: Icon(
                _isLoading
                    ? Icons.hourglass_top
                    : Icons.send_rounded,
                color: Colors.white,
                size: 19,
              ),
            ),
          ),
        ],
      ),
    );
  }
}