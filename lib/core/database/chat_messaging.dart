// import 'package:stream_chat_flutter/stream_chat_flutter.dart';

// class ChatService {
//   late final StreamChatClient _client;
//   late final Channel _channel;

//   // Initialize Stream Chat client and connect user
//   Future<void> init(String userId, String token) async {
//     _client = StreamChatClient(
//       'qg3xperd8afd', // Your Stream API key
//       logLevel: Level.INFO,
//     );

//     // Connect user to Stream
//     await _client.connectUser(
//       User(id: userId),
//       token,
//     );

//     // Join the channel (replace 'your-channel-id' with the actual channel ID)
//     _channel = _client.channel('messaging', id: 'your-channel-id');
//     await _channel.watch();
//   }

//   // Listen to new messages
//   Stream<Message> get messages => _channel.state!.messages;

//   // Send a new message
//   Future<void> sendMessage(String messageText) async {
//     final message = await _channel.sendMessage(Message(text: messageText));
//     print('Message sent: ${message.text}');
//   }

//   // Dispose method to clean up when done
//   void dispose() {
//     _client.disconnect();
//   }
// }
