// lib/services/stream_chat_service.dart

import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class StreamChatService {
  static StreamChatClient? client;

  static Future<void> initializeStreamChatClient(String token, String userId) async {
    // Initialize Stream Chat Client
    client = StreamChatClient(
      'qg3xperd8afd', // Replace with your actual Stream API key
      logLevel: Level.INFO,
    );

    // Connect to Stream Chat using the provided token
    await client?.connectUser(
      User(id: userId),
      token,
    );

    print('Stream client connected for user $userId');
  }
}
