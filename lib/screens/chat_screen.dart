import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../../../widgets/masked_chat_wrapper.dart'; // Import MaskedChatWrapper

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final channel = StreamChannel.of(context).channel;

    return MaskedChatWrapper(
      child: Scaffold(
        appBar: StreamChannelHeader(),
        body: Column(
          children: const [
            Expanded(child: StreamMessageListView()),
            StreamMessageInput(),
          ],
        ),
      ),
    );
  }
}
