import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:file_picker/file_picker.dart';
import '../../../widgets/masked_chat_wrapper.dart';
import 'package:flutter/cupertino.dart';
import '../../../widgets/mask_message.dart';

class ChatScreen extends StatefulWidget {
  final Channel channel;

  const ChatScreen({Key? key, required this.channel}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isMaskingEnabled = true;

  @override
  Widget build(BuildContext context) {
    return StreamChannel(
      channel: widget.channel,
      child: MaskedChatWrapper(
        child: Scaffold(
          appBar: StreamChannelHeader(),
          body: Column(
            children: [
              Expanded(
                child: StreamMessageListView(
                  messageFilter: (message) {
                    // Apply expiry filtering only to file attachments
                    if (message.attachments.isNotEmpty) {
                      final expiresAt = message.extraData['expires_at'];
                      if (expiresAt != null && expiresAt is int) {
                        return DateTime.now().millisecondsSinceEpoch < expiresAt;
                      }
                    }
                    return true; // Regular text messages are always visible
                  },
                  messageBuilder: (context, message, index, defaultWidget) {
                    return MaskMessage(message: message.message);
                  },
                ),
              ),
              StreamMessageInput(
                preMessageSending: (message) async {
                  Map<String, Object?> extraData = {...message.extraData};

                  // Apply expiry only for file attachments
                  if (message.attachments.isNotEmpty) {
                    int? expiryMinutes = await _showExpiryDialog(context);
                    if (expiryMinutes != null) {
                      final expiryTime = DateTime.now()
                          .add(Duration(minutes: expiryMinutes))
                          .millisecondsSinceEpoch;
                      extraData['expires_at'] = expiryTime;
                    }
                  }

                  // Keep the message masking functionality
                  extraData['mask_message'] = true;

                  return message.copyWith(extraData: extraData);
                },
                attachmentButtonBuilder: (context, onPressed) {
                  return IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: () async {
                      await _pickFile();
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      _disableMasking();

      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        PlatformFile file = result.files.first;
        final attachment = Attachment(
          type: 'file',
          file: AttachmentFile(
            path: file.path,
            size: file.size,
            name: file.name,
          ),
        );

        final expiryMinutes = await _showExpiryDialog(context);
        final expiryTime = expiryMinutes != null
            ? DateTime.now().add(Duration(minutes: expiryMinutes)).millisecondsSinceEpoch
            : null;

        final message = Message(
          attachments: [attachment],
        ).copyWith(extraData: {
          if (expiryTime != null) 'expires_at': expiryTime,
          'mask_message': true,
        });

        await widget.channel.sendMessage(message);
      }
    } catch (e) {
      print("❌ Error picking file: $e");
    } finally {
      _enableMasking();
    }
  }

  void _disableMasking() {
    setState(() => _isMaskingEnabled = false);
  }

  void _enableMasking() {
    setState(() => _isMaskingEnabled = true);
  }

  Future<int?> _showExpiryDialog(BuildContext context) async {
    Duration selectedDuration = const Duration(minutes: 5);

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
              Expanded(
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hm,
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
                  TextButton(
                    onPressed: () => Navigator.pop(context, null),
                    child: const Text(
                      'No Expiry',
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ),
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
