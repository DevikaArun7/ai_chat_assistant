
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';

class ChatStorageService {
  static const String _key = 'chat_messages';

  // Save messages
  Future<void> saveMessages(List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();

    final messageList = messages.map((message) {
      return {
        'text': message.text,
        'isUser': message.isUser,
      };
    }).toList();

    final jsonString = jsonEncode(messageList);

    await prefs.setString(_key, jsonString);
  }

  // Load messages
  Future<List<ChatMessage>> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString(_key);

    if (jsonString == null) {
      return [];
    }

    final List<dynamic> decodedList = jsonDecode(jsonString);

    return decodedList.map((item) {
      return ChatMessage(
        text: item['text'],
        isUser: item['isUser'],
      );
    }).toList();
  }

  // Clear messages
  Future<void> clearMessages() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_key);
  }
}
