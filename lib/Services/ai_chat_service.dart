
import 'dart:convert';
import 'dart:math';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/chat_message.dart';

class AiChatService {
  Future<String> getReply(List<ChatMessage> messages) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Gemini API key not found.');
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/'
      'models/gemini-3.8-flash:generateContent?key=$apiKey',
    );

    final contents = messages.map((message) {
      return {
        'role': message.isUser ? 'user' : 'model',
        'parts': [
          {'text': message.text}
        ],
      };
    }).toList();

    final requestBody = jsonEncode({
      'contents': contents,
    });

    for (int attempt = 0; attempt < 3; attempt++) {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final reply =
            data['candidates']?[0]?['content']?['parts']?[0]?['text'];

        if (reply == null) {
          throw Exception('No response received from Gemini.');
        }

        return reply.toString();
      }

      final shouldRetry = response.statusCode == 503 ||
          response.statusCode == 429 ||
          response.statusCode == 500 ||
          response.statusCode == 408;

      if (shouldRetry && attempt < 2) {
        final delaySeconds = pow(2, attempt).toInt();

        await Future.delayed(
          Duration(
            seconds: delaySeconds + Random().nextInt(2),
          ),
        );

        continue;
      }

      throw Exception(
        'Gemini API error: ${response.statusCode} - ${response.body}',
      );
    }

    throw Exception('Gemini is temporarily unavailable. Please try again.');
  }
}
