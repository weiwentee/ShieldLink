import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:shieldlink/widgets/SensitiveMessageWidget.dart';

class ChannelPage extends StatelessWidget {
  final VoidCallback onBack;

  const ChannelPage({Key? key, required this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            onBack();
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamMessageListView(
            messageBuilder: (context, details, messages, defaultWidget) {
            return SensitiveMessageWidget(message: details.message);
            },
          ),
          ),
          const StreamMessageInput(),
        ],
      ),
    );
  }
}
