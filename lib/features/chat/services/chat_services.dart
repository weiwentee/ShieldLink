// This file will handle Stream API interactions

import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChatService {
  final client = StreamChatClient(
    'b67pax5b2wdq',
    logLevel: Level.INFO,);

  Future<void> connectUser(String userId, String userName, String userToken) async {
    await client.connectUser(
      User(id: userId, extraData: {
        'name': userName,
      }),
      userToken,
    );
  }

  Future<void> disconnectUser() async {
    await client.disconnectUser();
  }

  Channel createChannel(String channelId, String name) {
    return client.channel(
      'messaging', 
      id: channelId,
      extraData: {
        'name': name,
      },
    );
  }
}