# AI Chat Assistant 

A Flutter-based AI Chat Assistant powered by the Gemini API. Users can send messages and receive AI-generated responses through a simple chat interface.

## Features

- Real-time AI responses using Gemini API
- User and assistant chat bubbles
- Loading indicator while waiting for responses
- Automatic retry for temporary API errors
- Local chat history using SharedPreferences
- Clear chat functionality
- Error handling

## Technologies Used

- Flutter
- Dart
- Gemini API
- REST API
- HTTP
- SharedPreferences
- Flutter Dotenv

## Project Structure


lib/
├── models/
│   └── chat_message.dart
├── services/
│   ├── ai_chat_service.dart
│   └── chat_storage_service.dart
├── screens/
│   └── chat_page.dart
├── widgets/
│   └── chat_bubble.dart
└── main.dart


## Setup Instructions

1. Download the project files from GitHub.
2. Open the project in VS Code or Android Studio.
3. Run `flutter pub get`.
4. Create a `.env` file in the project root.
5. Add your Gemini API key:

   GEMINI_API_KEY=_api_key

6. Run the app using `flutter run`.


## Author

Devika Arun

Flutter Developer