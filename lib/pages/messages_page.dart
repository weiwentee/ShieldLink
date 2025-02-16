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
  // Method to handle channel name update
  Future<void> _editChannelName(Channel channel) async {
    // Show a dialog to get the new channel name
    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        String input = '';
        return AlertDialog(
          title: const Text('Edit Channel Name'),
          content: TextField(
            onChanged: (value) {
              input = value;
            },
            decoration: const InputDecoration(hintText: 'Enter new channel name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog without saving
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(input); // Return the input value
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    // If a name was entered, update the channel
    if (newName != null && newName.trim().isNotEmpty) {
      try {
        await channel.update({'name': newName.trim()}); // Update the channel name
        setState(() {}); // Refresh the UI
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Channel name updated to "$newName"')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update channel name: $e')),
        );
      }
    }
  }

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

        return StreamBuilder<ChannelState>(
          stream: channel.state?.channelStateStream,
          builder: (context, snapshot) {
            String lastMessage = 'No messages yet.';
            if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data!.messages != null &&
                snapshot.data!.messages!.isNotEmpty) {
              final message = snapshot.data!.messages?.last;
              lastMessage = message?.text ?? 'Attachment';
            }

            // Extract the recipient's name
            final currentUser = StreamChat.of(context).currentUser;
            final recipient = channel.state?.members
                ?.firstWhere(
                  (member) => member.user?.id != currentUser?.id,
                  orElse: () => Member(user: User(id: 'default', name: 'Unknown')),
                )
                ?.user;

            final channelName = recipient?.name ?? 'Unnamed Channel';

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  channelName.isNotEmpty
                      ? channelName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(channelName),
              // subtitle: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editChannelName(channel), // Open edit dialog
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => StreamChannel(
                      channel: channel,
                      child: ChatScreen(channel: channel,),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
