
import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            const CircleAvatar(
              radius: 17,
              backgroundColor: Color(0xFFE9DDFB),
              child: Icon(
                Icons.auto_awesome,
                color: Color(0xFF6750A4),
                size: 19,
              ),
            ),
            const SizedBox(width: 9),
          ],

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF6750A4)
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 5),
                  bottomRight: Radius.circular(isUser ? 5 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                   color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: isUser
                      ? Colors.white
                      : const Color(0xFF292333),
                ),
              ),
            ),
          ),

          if (isUser) ...[
            const SizedBox(width: 9),
            const CircleAvatar(
              radius: 17,
              backgroundColor: Color(0xFFE9DDFB),
              child: Icon(
                Icons.person,
                color: Color(0xFF6750A4),
                size: 19,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
