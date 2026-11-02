class MockChatService {
  Future<String> getReply(String message) async {
    // Simulate the time taken by an AI service.
    await Future.delayed(const Duration(seconds: 1));

    final text = message.toLowerCase();

    if (text.contains('hello') || text.contains('hi')) {
      return 'Hello! How can I help you today?';
    }

    if (text.contains('flutter')) {
      return 'Flutter is a framework used to build apps '
          'for Android, iOS, web, and desktop.';
    }

    if (text.contains('api')) {
      return 'An API allows two applications to communicate '
          'with each other.';
    }

    if (text.contains('thank')) {
      return 'You are welcome!';
    }

    return 'That is an interesting question. '
        'I am a demo assistant, so my answers are limited.';
  }
}