import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:shieldlink/screens/chat_screen.dart';

class MessagesPage extends StatefulWidget {
  final List<Channel> channels;

  const MessagesPage({Key? key, required this.channels}) : super(key: key);

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  @override
  Widget build(BuildContext context) {
    // Check for empty channels
    if (widget.channels.isEmpty) {
      return const Center(
        child: Text(
          'No chats yet. Start a new chat!',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    // Display the list of channels if available
    return ListView.builder(
      itemCount: widget.channels.length,
      itemBuilder: (context, index) {
        final channel = widget.channels[index];
        return ListTile(
          title: Text(channel.name ?? 'Unnamed Channel'),
          subtitle: Text('Tap to open chat'),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => StreamChannel(
                  channel: channel,
                  child: ChatScreen(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}