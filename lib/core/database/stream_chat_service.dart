import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class StreamChatService {
  static final StreamChatClient client = StreamChatClient(
    "qg3xperd8afd",
    logLevel: Level.INFO,
  );

  static Future<void> connectUser(String userId, String userName, String userImage , String token) async {
    await client.connectUser(
      User(
        id: userId,
        name: userName,
        image: userImage,
      ),
      token ?? client.devToken(userId).rawValue, 
    
      
    );
  }
}
