import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class StreamChatService {
  static StreamChatClient? client;

  /// 🔹 Initialize Stream Chat Client
  static Future<void> initializeStreamChatClient(String token, String userId) async {
    if (client != null) {
      print("✅ Stream Chat Client already initialized.");
      return;
    }

    client = StreamChatClient(
      'qg3xperd8afd', // 🔹 Replace with your actual Stream API key
      logLevel: Level.INFO,
    );

    try {
      await client?.connectUser(
        User(
          id: userId,
          extraData: {
            'name': userId,
            'image': "https://via.placeholder.com/150", // Default profile picture
          },
        ),
        token, // ✅ Use the token fetched from the backend
      );

      print('✅ Stream client connected for user: $userId');
    } catch (e) {
      print('❌ Error connecting Stream Chat client: $e');
    }
  }

  /// 🔹 Create or Fetch a 1-on-1 Chat Channel
  static Future<Channel> createChannel(String currentUserId, String otherUserId) async {
    if (client == null) {
      throw Exception('Stream Chat Client not initialized!');
    }

    final channel = client!.channel(
      'messaging',
      id: '${currentUserId}_$otherUserId', // 🔹 Unique channel ID
      extraData: {
        'members': [currentUserId, otherUserId], // ✅ Both users must be members
      },
    );

    await channel.watch();
    print('✅ Channel created or fetched: ${channel.id}');
    return channel;
  }
}