import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../../../widgets/masked_chat_wrapper.dart'; // Import MaskedChatWrapper
import 'package:flutter/cupertino.dart'; 

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final channel = StreamChannel.of(context).channel;

    // Ensure user is watching the channel
    channel.watch();

    // Query the channel for messages
    _fetchMessages(channel);

    return MaskedChatWrapper(
      child: Scaffold(
        appBar: StreamChannelHeader(),
        body: Column(
          children: [
            Expanded(
              child: StreamMessageListView(
                messageFilter: (message) {
                  // ✅ Ensure extraData exists before accessing 'expires_at'
                  final expiresAt = message.extraData?['expires_at'];
                  if (expiresAt != null && expiresAt is int) {
                    return DateTime.now().millisecondsSinceEpoch < expiresAt;
                  }
                  return true;
                },
              ),
            ),

            StreamMessageInput(
              preMessageSending: (message) async {
                // ✅ Check if the message contains a file attachment
                if (message.attachments.isNotEmpty) {
                  int? expiryMinutes = await _showExpiryDialog(context);

                  // ✅ If user cancels expiry selection, don't add expiry
                  if (expiryMinutes == null) {
                    return message;
                  }

                  // ✅ Set the expiry timestamp
                  final expiryTime = DateTime.now()
                      .add(Duration(minutes: expiryMinutes))
                      .millisecondsSinceEpoch;

                  // ✅ Add expiry time to the file message only
                  final updatedMessage = message.copyWith(extraData: {
                    ...message.extraData ?? {}, // Ensure existing data is kept
                    'expires_at': expiryTime,
                  });

                  return updatedMessage;
                }
                // ✅ If it's a normal text message, send as-is
                return message;
              },
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Fetch messages from the channel
  void _fetchMessages(Channel channel) async {
    try {
      final channelState = await channel.query();
      print('Debug: Messages in channel: ${channelState.messages?.map((m) => m.text).toList() ?? []}');
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  // ✅ Show a dialog to set the expiry time of the file
  Future<int?> _showExpiryDialog(BuildContext context) async {
    Duration selectedDuration = const Duration(minutes: 5); // Default expiry time

    return await showModalBottomSheet<int>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Set File Expiry Time',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Scroll Piicker
              Expanded(
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hm, // Hours and minutes
                  initialTimerDuration: selectedDuration,
                  onTimerDurationChanged: (Duration newDuration) {
                    selectedDuration = newDuration;
                  },
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // No expiry button
                  TextButton(
                    onPressed: () => Navigator.pop(context, null),
                    child: const Text( 
                      'No Expiry',
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ),

                  // Confirm button
                  ElevatedButton(
                    onPressed: () {
                      int totalMinutes = selectedDuration.inMinutes;
                      Navigator.pop(context, totalMinutes > 0 ? totalMinutes : null);
                    },
                    child: const Text('Confirm'),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
